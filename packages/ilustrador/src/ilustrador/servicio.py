"""Orquestacion del pipeline de generacion."""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass, field
from pathlib import Path

from .almacen import guardar_imagen, listar_versiones, ruta_revision
from .catalogo import Catalogo, Proyecto
from .cliente import ClienteOpenRouter
from .errores import IlustracionError
from .prompts import cargar_referencia, construir_prompt, extraer_bloque_estilo
from .revision import crear_revision


@dataclass
class ResultadoGeneracion:
    """Resultado de una generacion, listo para CLI o MCP."""

    nombre: str
    modelo: str
    prompt: str
    aspecto: str
    fondo: str
    base: str | None = None
    originales: list[Path] = field(default_factory=list)
    revisiones: list[Path] = field(default_factory=list)
    coste: float | None = None

    def como_dict(self) -> dict:
        return {
            "nombre": self.nombre,
            "modelo": self.modelo,
            "aspecto": self.aspecto,
            "fondo": self.fondo,
            "base": self.base,
            "originales": [str(p) for p in self.originales],
            "revisiones": [str(p) for p in self.revisiones],
            "coste": self.coste,
            "prompt": self.prompt,
        }


def descripcion_compuesta(proyecto: Proyecto, catalogo: Catalogo, nombre: str) -> str:
    """Compone la descripcion base (si existe) y el delta de la variante."""
    activo = catalogo.obtener(nombre)
    partes: list[str] = []
    if activo.base:
        partes.append(descripcion_compuesta(proyecto, catalogo, activo.base))

    ruta = proyecto.ruta_descripcion(activo)
    if not ruta.is_file():
        raise IlustracionError(f"No se encontro la descripcion: {ruta}")
    partes.append(ruta.read_text(encoding="utf-8").strip())
    return "\n\n".join(partes)


def generar_ilustracion(
    proyecto: Proyecto,
    catalogo: Catalogo,
    nombre: str,
    *,
    modelo: str | None = None,
    fondo: str | None = None,
    aspecto: str | None = None,
    seed: int | None = None,
    referencias: Sequence[str | Path] = (),
    n: int = 1,
    resolution: str | None = None,
    crear_revisiones: bool = True,
    cliente: ClienteOpenRouter | None = None,
) -> ResultadoGeneracion:
    """Genera una ilustracion, la versiona y crea su copia de revision."""
    activo = catalogo.obtener(nombre)
    modelo = modelo or proyecto.modelo
    fondo = fondo or activo.fondo
    aspecto = aspecto or activo.aspecto

    descripcion = descripcion_compuesta(proyecto, catalogo, nombre)
    estilo = extraer_bloque_estilo(proyecto.guia_estilo)
    prompt = construir_prompt(descripcion, estilo, fondo)

    refs = [cargar_referencia(Path(ruta)) for ruta in referencias]
    cliente = cliente or ClienteOpenRouter.desde_entorno(
        proyecto.raiz, timeout=proyecto.timeout
    )

    respuesta = cliente.generar(
        prompt=prompt,
        modelo=modelo,
        aspecto=aspecto,
        resolution=resolution,
        n=n,
        seed=seed,
        referencias=refs,
    )

    resultado = ResultadoGeneracion(
        nombre=nombre,
        modelo=modelo,
        prompt=prompt,
        aspecto=aspecto,
        fondo=fondo,
        base=activo.base,
        coste=respuesta.coste,
    )

    for datos, media_type in zip(respuesta.imagenes, respuesta.media_types):
        original = guardar_imagen(proyecto.salida, nombre, datos, media_type)
        resultado.originales.append(original)
        if crear_revisiones:
            destino = ruta_revision(proyecto.revision, original)
            crear_revision(
                original,
                destino,
                max_lado=proyecto.revision_max,
                calidad=proyecto.revision_calidad,
            )
            resultado.revisiones.append(destino)

    return resultado


def preparar_revisiones(
    proyecto: Proyecto,
    catalogo: Catalogo,
    nombres: Sequence[str] | None = None,
    *,
    force: bool = False,
) -> list[dict]:
    """Genera o actualiza las copias ligeras de los activos indicados."""
    nombres = list(nombres) if nombres else catalogo.nombres()
    resultados: list[dict] = []

    for nombre in nombres:
        activo = catalogo.obtener(nombre)
        for original in listar_versiones(proyecto.salida, activo.nombre):
            destino = ruta_revision(proyecto.revision, original)
            if (
                not force
                and destino.is_file()
                and destino.stat().st_mtime >= original.stat().st_mtime
            ):
                resultados.append(
                    {
                        "original": str(original),
                        "revision": str(destino),
                        "actualizada": False,
                    }
                )
                continue

            crear_revision(
                original,
                destino,
                max_lado=proyecto.revision_max,
                calidad=proyecto.revision_calidad,
            )
            resultados.append(
                {
                    "original": str(original),
                    "revision": str(destino),
                    "actualizada": True,
                }
            )

    return resultados

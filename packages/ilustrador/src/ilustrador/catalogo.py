"""Catalogo de activos y configuracion del proyecto.

El paquete no conoce nombres concretos de personajes ni rutas del juego: todo
eso viene de un ``catalogo.toml`` que cada proyecto aporta.
"""

from __future__ import annotations

import tomllib
from dataclasses import dataclass
from pathlib import Path

from .errores import IlustracionError

CATEGORIAS = {"personaje", "objeto", "escenario"}
FONDOS = {"white", "magenta", "none"}


@dataclass(frozen=True)
class Activo:
    """Un elemento ilustrable del proyecto."""

    nombre: str
    categoria: str = "personaje"
    aspecto: str = "1:1"
    fondo: str = "white"
    descripcion: str | None = None
    base: str | None = None

    @property
    def archivo_descripcion(self) -> str:
        return self.descripcion or f"{self.nombre}.md"


@dataclass(frozen=True)
class Proyecto:
    """Rutas y ajustes de generacion de un proyecto."""

    raiz: Path
    descripciones: Path
    guia_estilo: Path
    salida: Path
    revision: Path
    modelo: str
    timeout: int = 300
    revision_max: int = 768
    revision_calidad: int = 82

    def ruta_descripcion(self, activo: Activo) -> Path:
        return self.descripciones / activo.archivo_descripcion


@dataclass(frozen=True)
class Catalogo:
    """Conjunto de activos indexados por nombre."""

    activos: dict[str, Activo]

    def obtener(self, nombre: str) -> Activo:
        try:
            return self.activos[nombre]
        except KeyError:
            disponibles = ", ".join(sorted(self.activos)) or "(vacio)"
            raise IlustracionError(
                f"Activo desconocido: {nombre}. Disponibles: {disponibles}"
            ) from None

    def nombres(self) -> list[str]:
        return sorted(self.activos)


def _resolver(raiz: Path, valor: str) -> Path:
    ruta = Path(valor)
    return ruta if ruta.is_absolute() else (raiz / ruta)


def cargar_proyecto(
    raiz: Path, catalogo: Path | None = None
) -> tuple[Proyecto, Catalogo]:
    """Carga ``catalogo.toml`` y devuelve la configuracion y los activos."""
    raiz = raiz.resolve()
    catalogo_path = catalogo or (raiz / "catalogo.toml")
    if not catalogo_path.is_file():
        raise IlustracionError(f"No se encontro el catalogo: {catalogo_path}")

    datos = tomllib.loads(catalogo_path.read_text(encoding="utf-8"))
    cfg = datos.get("proyecto", {})
    gen = datos.get("generacion", {})

    proyecto = Proyecto(
        raiz=raiz,
        descripciones=_resolver(
            raiz, cfg.get("descripciones", "Docu/Ilustraciones/Descripciones")
        ),
        guia_estilo=_resolver(
            raiz,
            cfg.get(
                "guia_estilo",
                "Docu/Ilustraciones/Descripciones/Guia_de_estilo_comun.md",
            ),
        ),
        salida=_resolver(raiz, cfg.get("salida", "Ilustraciones")),
        revision=_resolver(raiz, cfg.get("revision", "Ilustraciones/revision")),
        modelo=gen.get("modelo", "qwen/qwen-image-2.1-turbo"),
        timeout=int(gen.get("timeout", 300)),
        revision_max=int(gen.get("revision_max", 768)),
        revision_calidad=int(gen.get("revision_calidad", 82)),
    )

    crudos = datos.get("activos", [])
    if not crudos:
        raise IlustracionError(f"El catalogo {catalogo_path} no define activos.")

    por_nombre: dict[str, dict] = {}
    for item in crudos:
        nombre = item.get("nombre")
        if not nombre:
            raise IlustracionError("Cada activo necesita un 'nombre'.")
        if nombre in por_nombre:
            raise IlustracionError(f"Activo duplicado en el catalogo: {nombre}")
        por_nombre[nombre] = item

    def resolver(nombre: str, visitados: tuple[str, ...] = ()) -> Activo:
        if nombre in visitados:
            cadena = " -> ".join((*visitados, nombre))
            raise IlustracionError(f"Ciclo de herencia en el catalogo: {cadena}")

        item = por_nombre.get(nombre)
        if item is None:
            raise IlustracionError(f"Activo desconocido: {nombre}")

        base_nombre = item.get("base")
        base = None
        if base_nombre:
            if base_nombre == nombre:
                raise IlustracionError(
                    f"El activo {nombre} no puede heredar de si mismo."
                )
            base = resolver(base_nombre, (*visitados, nombre))

        categoria = item.get("categoria", base.categoria if base else "personaje")
        if categoria not in CATEGORIAS:
            raise IlustracionError(f"Categoria desconocida en {nombre}: {categoria}")

        fondo = item.get(
            "fondo",
            base.fondo if base else ("none" if categoria == "escenario" else "white"),
        )
        if fondo not in FONDOS:
            raise IlustracionError(f"Fondo desconocido en {nombre}: {fondo}")

        aspecto = item.get(
            "aspecto",
            base.aspecto if base else ("16:9" if categoria == "escenario" else "1:1"),
        )

        return Activo(
            nombre=nombre,
            categoria=categoria,
            aspecto=aspecto,
            fondo=fondo,
            descripcion=item.get("descripcion"),
            base=base_nombre,
        )

    activos = {nombre: resolver(nombre) for nombre in por_nombre}
    return proyecto, Catalogo(activos)

"""Servidor MCP del pipeline de ilustraciones."""

from __future__ import annotations

import argparse
from pathlib import Path

from fastmcp import FastMCP

from .almacen import listar_versiones
from .catalogo import Catalogo, Proyecto, cargar_proyecto
from .errores import IlustracionError
from .servicio import descripcion_compuesta
from .servicio import generar_ilustracion as _generar_ilustracion
from .servicio import preparar_revisiones as _preparar_revisiones
from .servicio import recortar_fondos as _recortar_fondos

mcp = FastMCP("Ilustrador")

_proyecto: Proyecto | None = None
_catalogo: Catalogo | None = None


def _contexto() -> tuple[Proyecto, Catalogo]:
    if _proyecto is None or _catalogo is None:
        raise IlustracionError("El servidor MCP no tiene proyecto configurado.")
    return _proyecto, _catalogo


@mcp.tool
def listar_activos() -> list[dict]:
    """Lista los activos del catalogo y sus versiones existentes."""
    proyecto, catalogo = _contexto()
    return [
        {
            "nombre": activo.nombre,
            "categoria": activo.categoria,
            "aspecto": activo.aspecto,
            "fondo": activo.fondo,
            "versiones": [
                ruta.name for ruta in listar_versiones(proyecto.salida, activo.nombre)
            ],
        }
        for activo in catalogo.activos.values()
    ]


@mcp.tool
def leer_descripcion(nombre: str) -> str:
    """Devuelve la descripcion completa del activo (base + variante)."""
    proyecto, catalogo = _contexto()
    return descripcion_compuesta(proyecto, catalogo, nombre)


@mcp.tool
def leer_guia_estilo() -> str:
    """Devuelve la guia de estilo comun del proyecto."""
    proyecto, _ = _contexto()
    if not proyecto.guia_estilo.is_file():
        raise IlustracionError(
            f"No se encontro la guia de estilo: {proyecto.guia_estilo}"
        )
    return proyecto.guia_estilo.read_text(encoding="utf-8")


@mcp.tool
def generar_ilustracion(
    nombre: str,
    modelo: str | None = None,
    fondo: str | None = None,
    aspecto: str | None = None,
    seed: int | None = None,
    referencias: list[str] | None = None,
    n: int = 1,
) -> dict:
    """Genera una ilustracion y devuelve originales, revisiones y coste.

    Usa la descripcion del catalogo y la guia de estilo del proyecto. La copia
    de revision es la que conviene adjuntar al chat para no agotar el contexto.
    """
    proyecto, catalogo = _contexto()
    resultado = _generar_ilustracion(
        proyecto,
        catalogo,
        nombre,
        modelo=modelo,
        fondo=fondo,
        aspecto=aspecto,
        seed=seed,
        referencias=referencias or (),
        n=n,
    )
    return resultado.como_dict()


@mcp.tool
def preparar_revision(nombre: str | None = None, force: bool = False) -> list[dict]:
    """Genera o actualiza las copias ligeras de revision."""
    proyecto, catalogo = _contexto()
    nombres = [nombre] if nombre else None
    return _preparar_revisiones(proyecto, catalogo, nombres, force=force)


@mcp.tool
def recortar_fondos(
    nombre: str | None = None,
    force: bool = False,
    tolerancia: int = 24,
    erosion: int = 1,
    recortar_margenes: bool = True,
    margen: int = 2,
    sangrar: bool = True,
    pasos_sangrado: int | None = None,
) -> list[dict]:
    """Recorta el fondo plano de las ilustraciones y deja PNG con transparencia.

    Los activos con fondo = "none" (los escenarios) se saltan. El recorte es un
    flood fill desde el borde, asi que los blancos que forman parte del dibujo
    se conservan. Despues se elimina el espacio transparente sobrante alrededor
    del dibujo, conservando ``margen`` pixeles de respiro (2 por defecto), y se
    rellena el RGB de los pixeles transparentes con el color opaco mas cercano
    (``sangrar``) para evitar halos al filtrar. Devuelve el PNG recortado y una
    copia de revision sobre tablero, que es la que conviene adjuntar al chat
    para no agotar el contexto.
    """
    proyecto, catalogo = _contexto()
    nombres = [nombre] if nombre else None
    return _recortar_fondos(
        proyecto,
        catalogo,
        nombres,
        force=force,
        tolerancia=tolerancia,
        erosion=erosion,
        recortar_margenes=recortar_margenes,
        margen=margen,
        sangrar=sangrar,
        pasos_sangrado=pasos_sangrado,
    )


def main(proyecto: Path, catalogo: Path | None = None) -> None:
    """Configura el servidor y lo arranca por stdio."""
    global _proyecto, _catalogo
    _proyecto, _catalogo = cargar_proyecto(proyecto, catalogo)
    mcp.run(show_banner=False)


def main_cli() -> None:
    parser = argparse.ArgumentParser(description="Servidor MCP de ilustraciones.")
    parser.add_argument("--proyecto", required=True, help="Raiz del proyecto.")
    parser.add_argument("--catalogo", default=None, help="Ruta al catalogo.toml.")
    args = parser.parse_args()
    main(Path(args.proyecto), Path(args.catalogo) if args.catalogo else None)

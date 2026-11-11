#!/usr/bin/env python3
"""Crea copias ligeras de las ilustraciones para revisarlas en el chat.

Genera Ilustraciones/revision/<nombre>.jpg a partir de las versiones del
catalogo, reduciendo el lado mayor (768 px por defecto) y comprimiendo a JPEG.
Asi el agente puede ver la imagen sin agotar el limite de contexto.

Los originales no se tocan: siguen en Ilustraciones/ para el juego.

Uso:
  python3 scripts/preparar_revision.py
  python3 scripts/preparar_revision.py --max 1024 --quality 85
  python3 scripts/preparar_revision.py Heroe_Chispita
  python3 scripts/preparar_revision.py --force
"""

import argparse
import sys
from dataclasses import replace
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RAIZ / "packages" / "ilustrador" / "src"))

from ilustrador.catalogo import cargar_proyecto
from ilustrador.errores import IlustracionError
from ilustrador.servicio import preparar_revisiones


def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "archivos",
        nargs="*",
        help="Nombres de activos (por defecto, todos los del catalogo)",
    )
    parser.add_argument("--max", type=int, default=None, help="Lado mayor en px")
    parser.add_argument("--quality", type=int, default=None, help="Calidad JPEG")
    parser.add_argument(
        "--force", action="store_true", help="Regenerar aunque ya exista la copia"
    )
    args = parser.parse_args()

    try:
        proyecto, catalogo = cargar_proyecto(RAIZ)
        if args.max is not None:
            proyecto = replace(proyecto, revision_max=args.max)
        if args.quality is not None:
            proyecto = replace(proyecto, revision_calidad=args.quality)

        nombres = [a.removesuffix(".md") for a in args.archivos] or None
        resultados = preparar_revisiones(proyecto, catalogo, nombres, force=args.force)

        for resultado in resultados:
            original = Path(resultado["original"])
            revision = Path(resultado["revision"])
            estado = "actualizada" if resultado["actualizada"] else "ya al dia"
            print(f"[{original.name}] {estado} -> {revision.relative_to(RAIZ)}")
    except IlustracionError as error:
        sys.exit(str(error))


if __name__ == "__main__":
    main()

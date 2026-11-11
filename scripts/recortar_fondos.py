#!/usr/bin/env python3
"""Recorta el fondo plano de las ilustraciones y deja PNG con transparencia.

Los activos con fondo = "none" (los escenarios) se saltan: no tienen fondo que
quitar. El recorte es un flood fill desde el borde, asi que los blancos y
magentas que forman parte del dibujo se conservan.

Uso:
  python3 scripts/recortar_fondos.py
  python3 scripts/recortar_fondos.py Heroe_Chispita Monstruo_Secuaz
  python3 scripts/recortar_fondos.py --tolerancia 32 --erosion 2
  python3 scripts/recortar_fondos.py --force
"""

import argparse
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RAIZ / "packages" / "ilustrador" / "src"))

from ilustrador.catalogo import cargar_proyecto
from ilustrador.errores import IlustracionError
from ilustrador.servicio import recortar_fondos


def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "archivos",
        nargs="*",
        help="Nombres de activos (por defecto, todos los del catalogo)",
    )
    parser.add_argument(
        "--tolerancia",
        type=int,
        default=24,
        help="Diferencia maxima por canal para considerar un pixel fondo (0-255)",
    )
    parser.add_argument(
        "--erosion",
        type=int,
        default=1,
        help="Pixeles a encoger el borde para quitar el halo del fondo",
    )
    parser.add_argument(
        "--force", action="store_true", help="Regenerar aunque ya exista el recorte"
    )
    args = parser.parse_args()

    try:
        proyecto, catalogo = cargar_proyecto(RAIZ)
        nombres = [a.removesuffix(".md") for a in args.archivos] or None
        resultados = recortar_fondos(
            proyecto,
            catalogo,
            nombres,
            force=args.force,
            tolerancia=args.tolerancia,
            erosion=args.erosion,
        )

        for resultado in resultados:
            original = Path(resultado["original"])
            recorte = Path(resultado["recorte"])
            estado = "recortado" if resultado["recortado"] else "ya al dia"
            print(f"[{original.name}] {estado} -> {recorte.relative_to(RAIZ)}")
    except IlustracionError as error:
        sys.exit(str(error))


if __name__ == "__main__":
    main()

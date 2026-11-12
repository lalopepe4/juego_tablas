#!/usr/bin/env python3
"""Recorta el fondo plano de las ilustraciones y deja PNG con transparencia.

Los activos con fondo = "none" (los escenarios) se saltan: no tienen fondo que
quitar. El recorte es un flood fill desde el borde, asi que los blancos y
magentas que forman parte del dibujo se conservan. Despues se elimina el
espacio transparente sobrante alrededor del dibujo y se rellena el RGB de los
pixeles transparentes con el color opaco mas cercano para evitar halos.

Uso:
  python3 scripts/recortar_fondos.py
  python3 scripts/recortar_fondos.py Heroe_Chispita Monstruo_Secuaz
  python3 scripts/recortar_fondos.py --tolerancia 32 --erosion 2
  python3 scripts/recortar_fondos.py --margen 4
  python3 scripts/recortar_fondos.py --sin-recorte-margenes
  python3 scripts/recortar_fondos.py --sin-sangrado
  python3 scripts/recortar_fondos.py --pasos-sangrado 8
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
        "--margen",
        type=int,
        default=2,
        help="Pixeles transparentes que se conservan alrededor del dibujo",
    )
    parser.add_argument(
        "--sin-recorte-margenes",
        dest="recortar_margenes",
        action="store_false",
        help="Conserva el lienzo original en vez de ajustarlo al dibujo",
    )
    parser.add_argument(
        "--sin-sangrado",
        dest="sangrar",
        action="store_false",
        help="No rellena el RGB de los pixeles transparentes",
    )
    parser.add_argument(
        "--pasos-sangrado",
        type=int,
        default=None,
        help="Capas de pixeles a rellenar (por defecto, todos los huecos)",
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
            recortar_margenes=args.recortar_margenes,
            margen=args.margen,
            sangrar=args.sangrar,
            pasos_sangrado=args.pasos_sangrado,
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

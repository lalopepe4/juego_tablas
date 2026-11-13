#!/usr/bin/env python3
"""Genera las ilustraciones del proyecto via la API de imagenes de OpenRouter.

Compone el prompt desde la descripcion del activo + la guia de estilo comun +
la directriz de fondo, llama a la API, guarda la imagen como
Ilustraciones/<nombre>_vNN.<ext> y crea una copia ligera en
Ilustraciones/revision/<nombre>_vNN.jpg.

Ejemplos:
  python3 scripts/generar_ilustraciones.py
  python3 scripts/generar_ilustraciones.py Heroe_Chispita
  python3 scripts/generar_ilustraciones.py --model google/gemini-nano-banana-2.1
  python3 scripts/generar_ilustraciones.py --bg none
  python3 scripts/generar_ilustraciones.py --ref Ilustraciones/Heroe_Chispita_v01.png
  python3 scripts/generar_ilustraciones.py --no-revision
"""

import argparse
import sys
from dataclasses import replace
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RAIZ / "packages" / "ilustrador" / "src"))

from ilustrador.catalogo import cargar_proyecto
from ilustrador.errores import IlustracionError
from ilustrador.servicio import generar_ilustracion


def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "archivos",
        nargs="*",
        help="Nombres de activos (por defecto, todos los del catalogo)",
    )
    parser.add_argument("--model", default=None, help="Modelo de imagen de OpenRouter")
    parser.add_argument(
        "--resolution",
        default=None,
        choices=["512", "768", "1K", "1.5K", "2K", "4K"],
        help="Omitir para usar la resolucion nativa del modelo",
    )
    parser.add_argument(
        "--aspect", default=None, help="Fuerza una relacion de aspecto para todos"
    )
    parser.add_argument(
        "--bg",
        default="auto",
        choices=["auto", "white", "magenta", "transparent", "none"],
        help="Fondo para recortar despues (auto: el del catalogo)",
    )
    parser.add_argument(
        "--background",
        default=None,
        choices=["auto", "transparent", "opaque"],
        help="Fondo nativo de la API (transparent requiere PNG/WebP)",
    )
    parser.add_argument(
        "--output-format",
        default=None,
        choices=["png", "jpeg", "webp", "svg", "gif"],
        help="Formato de salida solicitado a la API",
    )
    parser.add_argument("--n", type=int, default=1, help="Imagenes por prompt (1-6)")
    parser.add_argument("--seed", type=int, default=None)
    parser.add_argument(
        "--ref",
        action="append",
        default=[],
        help="Imagen local como referencia para coherencia (repetible)",
    )
    parser.add_argument("--timeout", type=int, default=None)
    parser.add_argument(
        "--no-revision",
        action="store_true",
        help="No crear la copia ligera para revision",
    )
    args = parser.parse_args()

    try:
        proyecto, catalogo = cargar_proyecto(RAIZ)
        if args.timeout is not None:
            proyecto = replace(proyecto, timeout=args.timeout)

        nombres = [a.removesuffix(".md") for a in args.archivos] or catalogo.nombres()
        for nombre in nombres:
            activo = catalogo.obtener(nombre)
            modelo = args.model or proyecto.modelo
            fondo = activo.fondo if args.bg == "auto" else args.bg
            aspecto = args.aspect or activo.aspecto
            print(
                f"[{nombre}] generando con {modelo} ({aspecto}, fondo={fondo})...",
                flush=True,
            )

            resultado = generar_ilustracion(
                proyecto,
                catalogo,
                nombre,
                modelo=args.model,
                fondo=None if args.bg == "auto" else args.bg,
                aspecto=args.aspect,
                seed=args.seed,
                referencias=args.ref,
                n=args.n,
                resolution=args.resolution,
                background=args.background,
                output_format=args.output_format,
                crear_revisiones=not args.no_revision,
            )

            for original in resultado.originales:
                print(f"[{nombre}] guardada -> {original.relative_to(RAIZ)}")
            for revision in resultado.revisiones:
                print(f"[{nombre}] revision -> {revision.relative_to(RAIZ)}")
            if resultado.coste is not None:
                print(f"[{nombre}] coste: ${resultado.coste:.4f}")
    except IlustracionError as error:
        sys.exit(str(error))


if __name__ == "__main__":
    main()

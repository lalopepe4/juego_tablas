"""Copias ligeras de las imagenes para revisarlas en el chat."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

from .errores import IlustracionError


def fondo_cuadros(tamano: tuple[int, int], lado: int = 16) -> Image.Image:
    """Fondo de tablero para que se vea la transparencia de los sprites."""
    fondo = Image.new("RGB", tamano, (255, 255, 255))
    dibujo = ImageDraw.Draw(fondo)
    for y in range(0, tamano[1], lado):
        for x in range(0, tamano[0], lado):
            if (x // lado + y // lado) % 2:
                dibujo.rectangle(
                    [x, y, x + lado - 1, y + lado - 1], fill=(214, 214, 214)
                )
    return fondo


def crear_revision(
    origen: Path,
    destino: Path,
    *,
    max_lado: int = 768,
    calidad: int = 82,
) -> Path:
    """Reduce ``origen`` y lo guarda como JPEG en ``destino``."""
    if not origen.is_file():
        raise IlustracionError(f"Imagen no encontrada: {origen}")

    destino.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(origen) as img:
        tiene_alfa = img.mode in ("RGBA", "LA") or (
            img.mode == "P" and "transparency" in img.info
        )
        img = img.convert("RGBA" if tiene_alfa else "RGB")
        img.thumbnail((max_lado, max_lado), Image.Resampling.LANCZOS)
        if tiene_alfa:
            fondo = fondo_cuadros(img.size)
            fondo.paste(img, mask=img.getchannel("A"))
            img = fondo
        img.save(destino, "JPEG", quality=calidad, optimize=True)
    return destino

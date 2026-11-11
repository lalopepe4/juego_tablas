"""Versionado y almacenamiento de imagenes generadas."""

from __future__ import annotations

from pathlib import Path

EXTENSION_POR_MIME = {
    "image/png": ".png",
    "image/jpeg": ".jpg",
    "image/webp": ".webp",
    "image/svg+xml": ".svg",
    "image/gif": ".gif",
}


def siguiente_version(directorio: Path, stem: str, extension: str) -> Path:
    """Devuelve la primera ruta ``<stem>_vNN<extension>`` libre."""
    n = 1
    while True:
        candidato = directorio / f"{stem}_v{n:02d}{extension}"
        if not candidato.exists():
            return candidato
        n += 1


def guardar_imagen(
    directorio: Path, nombre: str, datos: bytes, media_type: str
) -> Path:
    """Guarda ``datos`` con la siguiente version disponible."""
    directorio.mkdir(parents=True, exist_ok=True)
    extension = EXTENSION_POR_MIME.get(media_type, ".png")
    destino = siguiente_version(directorio, nombre, extension)
    destino.write_bytes(datos)
    return destino


def ruta_revision(directorio_revision: Path, original: Path) -> Path:
    """Ruta de la copia ligera correspondiente a un original."""
    return directorio_revision / f"{original.stem}.jpg"


def listar_versiones(directorio: Path, nombre: str) -> list[Path]:
    """Lista las versiones existentes de un activo."""
    if not directorio.is_dir():
        return []
    return sorted(directorio.glob(f"{nombre}_v*"))

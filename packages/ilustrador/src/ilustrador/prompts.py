"""Composicion de prompts y carga de referencias."""

from __future__ import annotations

import base64
from pathlib import Path

from .errores import IlustracionError

MIME_POR_EXTENSION = {
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".webp": "image/webp",
    ".gif": "image/gif",
}

DIRECTRIZ_FONDO = {
    "magenta": (
        "El personaje u objeto debe quedar aislado y completo sobre un fondo "
        "completamente liso de color magenta puro (#FF00FF), uniforme, sin "
        "sombras proyectadas ni reflejos en el suelo, para poder recortar la "
        "silueta con transparencia despues."
    ),
    "white": (
        "El personaje u objeto debe quedar aislado y completo sobre un fondo "
        "completamente blanco, uniforme, sin sombras proyectadas ni reflejos, "
        "para poder recortar la silueta con transparencia despues."
    ),
    "none": "",
}


def extraer_bloque_estilo(guia_estilo: Path) -> str:
    """Extrae el bloque de estilo comun de la guia en Markdown."""
    if not guia_estilo.is_file():
        raise IlustracionError(f"No se encontro la guia de estilo: {guia_estilo}")

    lineas = guia_estilo.read_text(encoding="utf-8").splitlines()
    bloque: list[str] = []
    dentro = False
    for linea in lineas:
        if linea.startswith("## "):
            dentro = linea.startswith("## Bloque breve")
            continue
        if dentro and linea.strip().startswith(">"):
            bloque.append(linea.strip().lstrip(">").strip())

    if not bloque:
        raise IlustracionError(f"No se encontro el bloque de estilo en {guia_estilo}")
    return " ".join(bloque)


def construir_prompt(descripcion: str, estilo: str, fondo: str) -> str:
    """Compone descripcion + estilo global + directriz de fondo."""
    if fondo not in DIRECTRIZ_FONDO:
        raise IlustracionError(f"Fondo desconocido: {fondo}")

    partes = [descripcion.strip(), f"Directrices de estilo globales: {estilo}"]
    if DIRECTRIZ_FONDO[fondo]:
        partes.append(DIRECTRIZ_FONDO[fondo])
    return "\n\n".join(partes)


def cargar_referencia(ruta: Path) -> dict:
    """Convierte una imagen local en una referencia data URL para la API."""
    if not ruta.is_file():
        raise IlustracionError(f"Referencia no encontrada: {ruta}")

    mime = MIME_POR_EXTENSION.get(ruta.suffix.lower(), "image/png")
    b64 = base64.b64encode(ruta.read_bytes()).decode()
    return {"type": "image_url", "image_url": {"url": f"data:{mime};base64,{b64}"}}

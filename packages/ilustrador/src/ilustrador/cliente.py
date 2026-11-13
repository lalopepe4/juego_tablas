"""Cliente de la API de imagenes de OpenRouter."""

from __future__ import annotations

import base64
import json
import os
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path

from .errores import IlustracionError

API_URL_POR_DEFECTO = "https://openrouter.ai/api/v1/images"


@dataclass
class RespuestaImagen:
    """Imagenes devueltas por la API, ya decodificadas."""

    imagenes: list[bytes]
    media_types: list[str]
    coste: float | None = None
    crudo: dict = field(default_factory=dict)


def cargar_dotenv(raiz: Path) -> None:
    """Carga ``OPENROUTER_API_KEY`` desde ``.env`` si no esta en el entorno."""
    if os.environ.get("OPENROUTER_API_KEY"):
        return

    dotenv = raiz / ".env"
    if not dotenv.is_file():
        return

    for linea in dotenv.read_text(encoding="utf-8").splitlines():
        linea = linea.strip()
        if not linea or linea.startswith("#") or "=" not in linea:
            continue
        clave, _, valor = linea.partition("=")
        if clave.strip() == "OPENROUTER_API_KEY":
            os.environ["OPENROUTER_API_KEY"] = valor.strip().strip('"').strip("'")
            return


class ClienteOpenRouter:
    """Cliente sincrono y sin dependencias externas para ``/api/v1/images``."""

    def __init__(
        self,
        api_key: str,
        *,
        api_url: str = API_URL_POR_DEFECTO,
        timeout: int = 300,
        titulo: str = "ilustrador",
    ) -> None:
        if not api_key:
            raise IlustracionError("Falta OPENROUTER_API_KEY.")
        self.api_key = api_key
        self.api_url = api_url
        self.timeout = timeout
        self.titulo = titulo

    @classmethod
    def desde_entorno(
        cls,
        raiz: Path,
        *,
        api_url: str = API_URL_POR_DEFECTO,
        timeout: int = 300,
        titulo: str = "ilustrador",
    ) -> ClienteOpenRouter:
        cargar_dotenv(raiz)
        return cls(
            os.environ.get("OPENROUTER_API_KEY", ""),
            api_url=api_url,
            timeout=timeout,
            titulo=titulo,
        )

    def generar(
        self,
        *,
        prompt: str,
        modelo: str,
        aspecto: str | None = None,
        resolution: str | None = None,
        n: int = 1,
        seed: int | None = None,
        referencias: list[dict] | None = None,
        background: str | None = None,
        output_format: str | None = None,
    ) -> RespuestaImagen:
        cuerpo: dict = {"model": modelo, "prompt": prompt, "n": n}
        # El endpoint de qwen-image rechaza resolution combinada con aspect_ratio.
        if resolution:
            cuerpo["resolution"] = resolution
        if aspecto:
            cuerpo["aspect_ratio"] = aspecto
        if seed is not None:
            cuerpo["seed"] = seed
        if referencias:
            cuerpo["input_references"] = referencias
        if background:
            cuerpo["background"] = background
        if output_format:
            cuerpo["output_format"] = output_format

        peticion = urllib.request.Request(
            self.api_url,
            data=json.dumps(cuerpo).encode(),
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
                "X-Title": self.titulo,
            },
            method="POST",
        )

        try:
            with urllib.request.urlopen(peticion, timeout=self.timeout) as respuesta:
                datos = json.load(respuesta)
        except urllib.error.HTTPError as error:
            detalle = error.read().decode(errors="replace")
            raise IlustracionError(
                f"Error HTTP {error.code} llamando a la API:\n{detalle}"
            ) from error
        except urllib.error.URLError as error:
            raise IlustracionError(
                f"Error de red llamando a la API: {error.reason}"
            ) from error

        items = datos.get("data") or []
        if not items:
            raise IlustracionError(
                f"La API no devolvio imagenes: {json.dumps(datos)[:400]}"
            )

        imagenes = [base64.b64decode(item["b64_json"]) for item in items]
        media_types = [item.get("media_type", "image/png") for item in items]
        uso = datos.get("usage") or {}
        return RespuestaImagen(
            imagenes=imagenes,
            media_types=media_types,
            coste=uso.get("cost"),
            crudo=datos,
        )

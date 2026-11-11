import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from ilustrador.prompts import (
    cargar_referencia,
    construir_prompt,
    extraer_bloque_estilo,
)


class PromptsTest(unittest.TestCase):
    def test_extraer_bloque_estilo(self):
        with tempfile.TemporaryDirectory() as tmp:
            guia = Path(tmp) / "guia.md"
            guia.write_text(
                "# Guia\n\n## Otra\n> no\n\n## Bloque breve\n> linea uno\n> linea dos\n",
                encoding="utf-8",
            )
            self.assertEqual(extraer_bloque_estilo(guia), "linea uno linea dos")

    def test_construir_prompt_con_fondo(self):
        prompt = construir_prompt("Un unicornio", "Estilo cartoon", "white")
        self.assertIn("Un unicornio", prompt)
        self.assertIn("Estilo cartoon", prompt)
        self.assertIn("fondo completamente blanco", prompt)

    def test_construir_prompt_sin_fondo(self):
        prompt = construir_prompt("Un mapa", "Estilo cartoon", "none")
        self.assertNotIn("fondo completamente", prompt)

    def test_cargar_referencia(self):
        with tempfile.TemporaryDirectory() as tmp:
            ruta = Path(tmp) / "ref.png"
            ruta.write_bytes(b"\x89PNG\r\n\x1a\n")
            ref = cargar_referencia(ruta)
            self.assertEqual(ref["type"], "image_url")
            self.assertTrue(
                ref["image_url"]["url"].startswith("data:image/png;base64,")
            )


if __name__ == "__main__":
    unittest.main()

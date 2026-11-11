import sys
import tempfile
import unittest
from io import BytesIO
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from PIL import Image

from ilustrador.catalogo import cargar_proyecto
from ilustrador.cliente import RespuestaImagen
from ilustrador.servicio import generar_ilustracion, preparar_revisiones


def _png() -> bytes:
    buffer = BytesIO()
    Image.new("RGB", (8, 8), (255, 0, 0)).save(buffer, "PNG")
    return buffer.getvalue()


class ClienteFalso:
    def __init__(self):
        self.llamadas = []

    def generar(self, **kwargs):
        self.llamadas.append(kwargs)
        return RespuestaImagen(
            imagenes=[_png()],
            media_types=["image/png"],
            coste=0.0123,
        )


class ServicioTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.raiz = Path(self.tmp.name)
        descripciones = self.raiz / "Docu" / "Ilustraciones" / "Descripciones"
        descripciones.mkdir(parents=True)
        (self.raiz / "Ilustraciones").mkdir()

        (descripciones / "Heroe.md").write_text(
            "Un unicornio con crin de arcoiris.", encoding="utf-8"
        )
        (descripciones / "Heroe_sorprendido.md").write_text(
            "Expresión: sorprendido, ojos muy abiertos.", encoding="utf-8"
        )
        (descripciones / "Guia.md").write_text(
            "## Bloque breve\n> Estilo cartoon\n> Colores vivos\n",
            encoding="utf-8",
        )
        (self.raiz / "catalogo.toml").write_text(
            """
[proyecto]
descripciones = "Docu/Ilustraciones/Descripciones"
guia_estilo = "Docu/Ilustraciones/Descripciones/Guia.md"
salida = "Ilustraciones"
revision = "Ilustraciones/revision"

[generacion]
modelo = "modelo/prueba"
revision_max = 64
revision_calidad = 80

[[activos]]
nombre = "Heroe"
categoria = "personaje"
aspecto = "1:1"
fondo = "white"

[[activos]]
nombre = "Heroe_sorprendido"
base = "Heroe"
descripcion = "Heroe_sorprendido.md"
""",
            encoding="utf-8",
        )
        self.proyecto, self.catalogo = cargar_proyecto(self.raiz)

    def tearDown(self):
        self.tmp.cleanup()

    def test_genera_original_y_revision(self):
        cliente = ClienteFalso()
        resultado = generar_ilustracion(
            self.proyecto, self.catalogo, "Heroe", cliente=cliente
        )

        self.assertEqual(len(resultado.originales), 1)
        self.assertEqual(len(resultado.revisiones), 1)
        self.assertTrue(resultado.originales[0].is_file())
        self.assertTrue(resultado.revisiones[0].is_file())
        self.assertAlmostEqual(resultado.coste, 0.0123)
        self.assertIn("Un unicornio", resultado.prompt)
        self.assertIn("Estilo cartoon", resultado.prompt)
        self.assertEqual(cliente.llamadas[0]["modelo"], "modelo/prueba")
        self.assertEqual(cliente.llamadas[0]["aspecto"], "1:1")

    def test_variante_compone_base_y_delta(self):
        cliente = ClienteFalso()
        resultado = generar_ilustracion(
            self.proyecto, self.catalogo, "Heroe_sorprendido", cliente=cliente
        )
        self.assertIn("Un unicornio", resultado.prompt)
        self.assertIn("sorprendido", resultado.prompt)
        self.assertEqual(resultado.base, "Heroe")
        self.assertEqual(resultado.originales[0].name, "Heroe_sorprendido_v01.png")

    def test_preparar_revisiones(self):
        cliente = ClienteFalso()
        generar_ilustracion(self.proyecto, self.catalogo, "Heroe", cliente=cliente)
        resultados = preparar_revisiones(self.proyecto, self.catalogo)
        self.assertEqual(len(resultados), 1)
        self.assertTrue(Path(resultados[0]["revision"]).is_file())


if __name__ == "__main__":
    unittest.main()

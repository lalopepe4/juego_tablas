import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from ilustrador.catalogo import cargar_proyecto
from ilustrador.errores import IlustracionError


class CatalogoTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.raiz = Path(self.tmp.name)
        (self.raiz / "catalogo.toml").write_text(
            """
[proyecto]
descripciones = "Descripciones"
guia_estilo = "Descripciones/Guia.md"
salida = "Salida"
revision = "Salida/revision"

[[activos]]
nombre = "Heroe"

[[activos]]
nombre = "Heroe_sorprendido"
base = "Heroe"
descripcion = "Heroe_sorprendido.md"

[[activos]]
nombre = "Mapa"
categoria = "escenario"
""",
            encoding="utf-8",
        )
        self.proyecto, self.catalogo = cargar_proyecto(self.raiz)

    def tearDown(self):
        self.tmp.cleanup()

    def test_defaults_por_categoria(self):
        heroe = self.catalogo.obtener("Heroe")
        self.assertEqual(heroe.categoria, "personaje")
        self.assertEqual(heroe.fondo, "white")
        self.assertEqual(heroe.aspecto, "1:1")

        mapa = self.catalogo.obtener("Mapa")
        self.assertEqual(mapa.fondo, "none")
        self.assertEqual(mapa.aspecto, "16:9")

    def test_variante_hereda_de_la_base(self):
        variante = self.catalogo.obtener("Heroe_sorprendido")
        self.assertEqual(variante.base, "Heroe")
        self.assertEqual(variante.categoria, "personaje")
        self.assertEqual(variante.fondo, "white")
        self.assertEqual(variante.aspecto, "1:1")
        self.assertEqual(variante.archivo_descripcion, "Heroe_sorprendido.md")

    def test_activo_desconocido(self):
        with self.assertRaises(IlustracionError):
            self.catalogo.obtener("NoExiste")

    def test_base_desconocida(self):
        with tempfile.TemporaryDirectory() as tmp:
            raiz = Path(tmp)
            (raiz / "catalogo.toml").write_text(
                """
[proyecto]
[[activos]]
nombre = "Variante"
base = "NoExiste"
""",
                encoding="utf-8",
            )
            with self.assertRaises(IlustracionError):
                cargar_proyecto(raiz)

    def test_ciclo_de_herencia(self):
        with tempfile.TemporaryDirectory() as tmp:
            raiz = Path(tmp)
            (raiz / "catalogo.toml").write_text(
                """
[proyecto]
[[activos]]
nombre = "A"
base = "B"
[[activos]]
nombre = "B"
base = "A"
""",
                encoding="utf-8",
            )
            with self.assertRaises(IlustracionError):
                cargar_proyecto(raiz)

    def test_rutas_resueltas(self):
        self.assertEqual(self.proyecto.descripciones, self.raiz / "Descripciones")
        self.assertEqual(self.proyecto.salida, self.raiz / "Salida")


if __name__ == "__main__":
    unittest.main()

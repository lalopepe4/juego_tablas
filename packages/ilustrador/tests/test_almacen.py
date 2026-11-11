import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from ilustrador.almacen import guardar_imagen, ruta_revision, siguiente_version


class AlmacenTest(unittest.TestCase):
    def test_siguiente_version(self):
        with tempfile.TemporaryDirectory() as tmp:
            directorio = Path(tmp)
            self.assertEqual(
                siguiente_version(directorio, "Heroe", ".png").name,
                "Heroe_v01.png",
            )
            (directorio / "Heroe_v01.png").write_bytes(b"x")
            self.assertEqual(
                siguiente_version(directorio, "Heroe", ".png").name,
                "Heroe_v02.png",
            )

    def test_guardar_imagen(self):
        with tempfile.TemporaryDirectory() as tmp:
            directorio = Path(tmp)
            destino = guardar_imagen(directorio, "Heroe", b"datos", "image/png")
            self.assertTrue(destino.is_file())
            self.assertEqual(destino.read_bytes(), b"datos")

    def test_ruta_revision(self):
        self.assertEqual(
            ruta_revision(Path("/tmp/rev"), Path("/tmp/Heroe_v01.png")).name,
            "Heroe_v01.jpg",
        )


if __name__ == "__main__":
    unittest.main()

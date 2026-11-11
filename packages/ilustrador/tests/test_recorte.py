import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from ilustrador.recorte import color_de_fondo, recortar_archivo, recortar_fondo

from ilustrador.errores import IlustracionError


def _imagen_con_hueco(
    color_fondo: tuple[int, int, int] = (255, 255, 255),
    color_figura: tuple[int, int, int] = (200, 30, 30),
) -> Image.Image:
    """Figura centrada con un hueco del color del fondo en su interior."""
    img = Image.new("RGB", (60, 60), color_fondo)
    dibujo = ImageDraw.Draw(img)
    dibujo.rectangle([10, 10, 49, 49], fill=color_figura)
    dibujo.rectangle([25, 25, 34, 34], fill=color_fondo)
    return img


class RecorteTest(unittest.TestCase):
    def test_deduce_el_color_de_fondo(self):
        self.assertEqual(color_de_fondo(_imagen_con_hueco()), (255, 255, 255))
        self.assertEqual(
            color_de_fondo(_imagen_con_hueco(color_fondo=(255, 0, 255))),
            (255, 0, 255),
        )

    def test_quita_el_fondo_y_conserva_el_hueco(self):
        resultado = recortar_fondo(_imagen_con_hueco(), erosion=0)
        self.assertEqual(resultado.mode, "RGBA")
        self.assertEqual(resultado.getpixel((0, 0))[3], 0)
        self.assertEqual(resultado.getpixel((5, 5))[3], 0)
        self.assertEqual(resultado.getpixel((15, 15))[3], 255)
        # El hueco interior no esta conectado al borde: se conserva.
        self.assertEqual(resultado.getpixel((30, 30))[3], 255)

    def test_erosion_encoge_el_borde(self):
        sin_erosion = recortar_fondo(_imagen_con_hueco(), erosion=0)
        con_erosion = recortar_fondo(_imagen_con_hueco(), erosion=1)
        self.assertEqual(sin_erosion.getpixel((10, 10))[3], 255)
        self.assertEqual(con_erosion.getpixel((10, 10))[3], 0)

    def test_fondo_magenta(self):
        resultado = recortar_fondo(
            _imagen_con_hueco(color_fondo=(255, 0, 255)), erosion=0
        )
        self.assertEqual(resultado.getpixel((0, 0))[3], 0)
        self.assertEqual(resultado.getpixel((15, 15))[3], 255)

    def test_tolerancia_invalida(self):
        with self.assertRaises(IlustracionError):
            recortar_fondo(_imagen_con_hueco(), tolerancia=300)

    def test_recortar_archivo_escribe_png_con_alfa(self):
        with tempfile.TemporaryDirectory() as tmp:
            origen = Path(tmp) / "figura.png"
            destino = Path(tmp) / "salida" / "figura.png"
            _imagen_con_hueco().save(origen)

            recortar_archivo(origen, destino, erosion=0)

            self.assertTrue(destino.is_file())
            with Image.open(destino) as img:
                self.assertEqual(img.mode, "RGBA")
                self.assertEqual(img.getpixel((0, 0))[3], 0)
                self.assertEqual(img.getpixel((15, 15))[3], 255)

    def test_archivo_inexistente(self):
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaises(IlustracionError):
                recortar_archivo(Path(tmp) / "no.png", Path(tmp) / "si.png")


if __name__ == "__main__":
    unittest.main()

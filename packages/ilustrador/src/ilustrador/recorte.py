"""Recorte del fondo plano de las ilustraciones.

Las ilustraciones de personajes y objetos se generan sobre un fondo liso
(blanco o magenta) precisamente para poder recortarlas. Este modulo convierte
ese fondo en transparencia.

El recorte es un *flood fill* desde el borde, no un filtro por color: asi los
blancos y magentas que forman parte del dibujo (los ojos de Chispita, por
ejemplo) se conservan, porque no estan conectados con el borde de la imagen.
"""

from __future__ import annotations

from collections import Counter, deque
from pathlib import Path

from PIL import Image, ImageChops, ImageFilter

from .errores import IlustracionError

COLORES_FONDO = {
    "white": (255, 255, 255),
    "magenta": (255, 0, 255),
}


def color_de_fondo(img: Image.Image) -> tuple[int, int, int]:
    """Deduce el color del fondo mirando el borde de la imagen.

    Se usa el color mas frecuente del marco exterior en lugar de una esquina
    suelta, para que un personaje que roce una esquina no lo desvie.
    """
    rgb = img.convert("RGB")
    ancho, alto = rgb.size
    pixeles = rgb.load()
    muestras: list[tuple[int, int, int]] = []
    for x in range(ancho):
        muestras.append(pixeles[x, 0])
        muestras.append(pixeles[x, alto - 1])
    for y in range(alto):
        muestras.append(pixeles[0, y])
        muestras.append(pixeles[ancho - 1, y])
    return Counter(muestras).most_common(1)[0][0]


def recortar_fondo(
    img: Image.Image,
    *,
    color_fondo: tuple[int, int, int] | None = None,
    tolerancia: int = 24,
    erosion: int = 1,
) -> Image.Image:
    """Devuelve una copia RGBA con el fondo plano vuelto transparente.

    ``tolerancia`` es la diferencia maxima por canal para considerar que un
    pixel es fondo. ``erosion`` encoge el borde del dibujo unos pixeles para
    eliminar el halo semitransparente que deja el antialias contra el fondo.
    """
    if not 0 <= tolerancia <= 255:
        raise IlustracionError(f"Tolerancia fuera de rango: {tolerancia}")
    if erosion < 0:
        raise IlustracionError(f"Erosion invalida: {erosion}")

    original = img.convert("RGBA")
    fondo = color_fondo or color_de_fondo(original)
    mascara = _mascara_fondo_conectado(original, fondo, tolerancia)

    alfa = mascara.point(lambda valor: 0 if valor else 255)
    if erosion:
        alfa = alfa.filter(ImageFilter.MinFilter(erosion * 2 + 1))
    alfa = ImageChops.multiply(alfa, original.getchannel("A"))

    resultado = original.copy()
    resultado.putalpha(alfa)
    return resultado


def recortar_margenes_transparentes(
    img: Image.Image, *, margen: int = 0
) -> Image.Image:
    """Recorta el espacio transparente que sobra alrededor del dibujo.

    ``margen`` conserva ese numero de pixeles transparentes alrededor del
    contenido: un pequeno respiro evita que el filtrado del motor corte el
    borde del sprite al escalarlo. Con ``margen = 0`` la imagen queda ajustada
    al contenido.
    """
    if margen < 0:
        raise IlustracionError(f"Margen invalido: {margen}")

    original = img.convert("RGBA")
    caja = original.getchannel("A").getbbox()
    if caja is None:
        return original

    izquierda, arriba, derecha, abajo = caja
    return original.crop(
        (
            max(0, izquierda - margen),
            max(0, arriba - margen),
            min(original.width, derecha + margen),
            min(original.height, abajo + margen),
        )
    )


def sangrar_color(img: Image.Image, *, pasos: int | None = None) -> Image.Image:
    """Rellena el RGB de los pixeles transparentes con el color opaco mas cercano.

    El canal alfa no se toca: los pixeles siguen siendo transparentes. El
    relleno solo importa cuando el motor filtra el borde, porque evita que el
    color del fondo (blanco o magenta) se mezcle con el dibujo y deje un halo.

    ``pasos`` limita cuantas capas de pixeles se rellenan desde el borde. Con
    ``None`` se rellenan todos los pixeles transparentes alcanzables, incluidos
    los huecos internos (entre patas, brazos, etc.).
    """
    if pasos is not None and pasos < 0:
        raise IlustracionError(f"Pasos invalidos: {pasos}")

    original = img.convert("RGBA")
    ancho, alto = original.size
    datos = bytearray(original.tobytes())
    visitado = bytearray(ancho * alto)
    cola: deque[int] = deque()

    # Los pixeles opacos ya tienen color; se encolan los que tocan transparencia
    # para empezar a propagar desde el borde del dibujo.
    for y in range(alto):
        base = y * ancho
        for x in range(ancho):
            indice = base + x
            i = indice * 4
            if not datos[i + 3]:
                continue
            visitado[indice] = 1
            if (
                (x > 0 and not datos[i - 1])
                or (x < ancho - 1 and not datos[i + 7])
                or (y > 0 and not datos[i - 4 * ancho + 3])
                or (y < alto - 1 and not datos[i + 4 * ancho + 3])
            ):
                cola.append(indice)

    capa = 0
    while cola:
        if pasos is not None and capa >= pasos:
            break
        for _ in range(len(cola)):
            indice = cola.popleft()
            i = indice * 4
            rojo, verde, azul = datos[i], datos[i + 1], datos[i + 2]
            x = indice % ancho
            y = indice // ancho
            if x > 0:
                _sangrar_vecino(datos, visitado, cola, indice - 1, rojo, verde, azul)
            if x < ancho - 1:
                _sangrar_vecino(datos, visitado, cola, indice + 1, rojo, verde, azul)
            if y > 0:
                _sangrar_vecino(
                    datos, visitado, cola, indice - ancho, rojo, verde, azul
                )
            if y < alto - 1:
                _sangrar_vecino(
                    datos, visitado, cola, indice + ancho, rojo, verde, azul
                )
        capa += 1

    return Image.frombytes("RGBA", (ancho, alto), bytes(datos))


def _sangrar_vecino(
    datos: bytearray,
    visitado: bytearray,
    cola: deque[int],
    indice: int,
    rojo: int,
    verde: int,
    azul: int,
) -> None:
    """Copia el color a un vecino transparente y lo encola."""
    if visitado[indice]:
        return
    i = indice * 4
    if datos[i + 3]:
        return
    datos[i] = rojo
    datos[i + 1] = verde
    datos[i + 2] = azul
    visitado[indice] = 1
    cola.append(indice)


def recortar_archivo(
    origen: Path,
    destino: Path,
    *,
    tolerancia: int = 24,
    erosion: int = 1,
    recortar_margenes: bool = True,
    margen: int = 2,
    sangrar: bool = True,
    pasos_sangrado: int | None = None,
) -> Path:
    """Recorta ``origen`` y guarda el PNG transparente en ``destino``.

    Ademas del fondo, elimina el espacio transparente sobrante alrededor del
    dibujo salvo que ``recortar_margenes`` sea falso. Por defecto conserva 2
    pixeles de respiro: el filtrado bilineal de Godot necesita al menos 1 para
    mezclar el borde, y 2 dan margen para rotaciones y escalados.

    ``sangrar`` rellena el RGB de los pixeles transparentes con el color opaco
    mas cercano para evitar halos al filtrar; ``pasos_sangrado`` limita cuantas
    capas se rellenan (``None`` rellena tambien los huecos internos).
    """
    if not origen.is_file():
        raise IlustracionError(f"Imagen no encontrada: {origen}")

    destino.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(origen) as img:
        resultado = recortar_fondo(img, tolerancia=tolerancia, erosion=erosion)
        if recortar_margenes:
            resultado = recortar_margenes_transparentes(resultado, margen=margen)
        if sangrar:
            resultado = sangrar_color(resultado, pasos=pasos_sangrado)
        resultado.save(destino, "PNG", optimize=True)
    return destino


def _mascara_fondo_conectado(
    img: Image.Image, fondo: tuple[int, int, int], tolerancia: int
) -> Image.Image:
    """Mascara L con 255 en el fondo que se alcanza desde el borde."""
    rgb = img.convert("RGB")
    ancho, alto = rgb.size

    diferencia = ImageChops.difference(rgb, Image.new("RGB", rgb.size, fondo))
    rojo, verde, azul = diferencia.split()
    distancia = ImageChops.lighter(ImageChops.lighter(rojo, verde), azul)
    candidato = distancia.point(
        lambda valor: 255 if valor <= tolerancia else 0, mode="L"
    )

    datos = candidato.tobytes()
    visitado = bytearray(ancho * alto)
    pila = _semillas(datos, ancho, alto)

    while pila:
        x, y = pila.pop()
        base = y * ancho
        if visitado[base + x] or not datos[base + x]:
            continue

        izquierda = x
        while (
            izquierda > 0
            and datos[base + izquierda - 1]
            and not visitado[base + izquierda - 1]
        ):
            izquierda -= 1
        derecha = x
        while (
            derecha < ancho - 1
            and datos[base + derecha + 1]
            and not visitado[base + derecha + 1]
        ):
            derecha += 1

        for xi in range(izquierda, derecha + 1):
            visitado[base + xi] = 1

        for fila in (y - 1, y + 1):
            if fila < 0 or fila >= alto:
                continue
            base_fila = fila * ancho
            en_tramo = False
            for xi in range(izquierda, derecha + 1):
                indice = base_fila + xi
                if datos[indice] and not visitado[indice]:
                    if not en_tramo:
                        pila.append((xi, fila))
                        en_tramo = True
                else:
                    en_tramo = False

    return Image.frombytes("L", (ancho, alto), bytes(visitado))


def _semillas(datos: bytes, ancho: int, alto: int) -> list[tuple[int, int]]:
    """Pixeles del borde que pueden ser fondo."""
    semillas: list[tuple[int, int]] = []
    for x in range(ancho):
        if datos[x]:
            semillas.append((x, 0))
        if datos[(alto - 1) * ancho + x]:
            semillas.append((x, alto - 1))
    for y in range(alto):
        if datos[y * ancho]:
            semillas.append((0, y))
        if datos[y * ancho + ancho - 1]:
            semillas.append((ancho - 1, y))
    return semillas

# ilustrador

Pipeline reutilizable para generar ilustraciones con la API de imagenes de OpenRouter,
versionarlas y crear copias ligeras para revision.

## Instalacion

```bash
pip install -e packages/ilustrador
```

## Uso como libreria

```python
from pathlib import Path
from ilustrador.catalogo import cargar_proyecto
from ilustrador.servicio import generar_ilustracion

proyecto, catalogo = cargar_proyecto(Path("/ruta/al/proyecto"))
resultado = generar_ilustracion(proyecto, catalogo, "Heroe_Chispita")
print(resultado.originales, resultado.revisiones)
```

## Recorte de fondos

Las ilustraciones de personajes y objetos se generan sobre un fondo liso
precisamente para poder recortarlas. `recortar_fondos` convierte ese fondo en
transparencia con un flood fill desde el borde, asi que los blancos y magentas
que forman parte del dibujo se conservan (no estan conectados con el borde).
Despues elimina el espacio transparente sobrante alrededor del dibujo, de modo
que el PNG queda ajustado al contenido, y rellena el RGB de los pixeles
transparentes con el color opaco mas cercano (_color bleed_). Ese relleno no
cambia el alfa: solo evita que el blanco o el magenta del fondo se mezclen con
el dibujo al filtrar el borde y dejen un halo.

```bash
python3 scripts/recortar_fondos.py
python3 scripts/recortar_fondos.py Heroe_Chispita --tolerancia 32 --erosion 2
python3 scripts/recortar_fondos.py --margen 4
python3 scripts/recortar_fondos.py --sin-recorte-margenes
python3 scripts/recortar_fondos.py --sin-sangrado
python3 scripts/recortar_fondos.py --pasos-sangrado 8
```

`--margen` conserva unos pixeles de respiro alrededor del dibujo (2 por
defecto, suficiente para el filtrado bilineal de Godot),
`--sin-recorte-margenes` mantiene el lienzo original y `--sin-sangrado`
desactiva el relleno de color. Por defecto el sangrado rellena todos los
huecos internos; `--pasos-sangrado` limita cuantas capas se rellenan.

Los PNG resultantes van a `Ilustraciones/recortes/`, configurable con la clave
`recortes` de `[proyecto]` en el catalogo. Los activos con `fondo = "none"`
(los escenarios) se saltan.

## Uso como MCP

```bash
ilustrador-mcp --proyecto /ruta/al/proyecto
```

El proyecto debe tener un `catalogo.toml` en la raiz (o pasar `--catalogo`).
La API key se lee de `OPENROUTER_API_KEY` o del `.env` del proyecto.

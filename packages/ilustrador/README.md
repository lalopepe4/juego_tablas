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

```bash
python3 scripts/recortar_fondos.py
python3 scripts/recortar_fondos.py Heroe_Chispita --tolerancia 32 --erosion 2
```

Los PNG resultantes van a `Ilustraciones/recortes/`, configurable con la clave
`recortes` de `[proyecto]` en el catalogo. Los activos con `fondo = "none"`
(los escenarios) se saltan.

## Uso como MCP

```bash
ilustrador-mcp --proyecto /ruta/al/proyecto
```

El proyecto debe tener un `catalogo.toml` en la raiz (o pasar `--catalogo`).
La API key se lee de `OPENROUTER_API_KEY` o del `.env` del proyecto.

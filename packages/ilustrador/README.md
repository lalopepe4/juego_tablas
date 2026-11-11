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

## Uso como MCP

```bash
ilustrador-mcp --proyecto /ruta/al/proyecto
```

El proyecto debe tener un `catalogo.toml` en la raiz (o pasar `--catalogo`).
La API key se lee de `OPENROUTER_API_KEY` o del `.env` del proyecto.

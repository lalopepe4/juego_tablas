# Plan: MCP de ilustraciones

## Objetivo

Convertir el pipeline actual (`generar_ilustraciones.py` + `preparar_revision.py`) en:

1. Un paquete Python reutilizable (`packages/ilustrador/`).
2. Un CLI que conserva el flujo actual.
3. Un servidor MCP que expone el pipeline al agente de Zed.

La genericidad se logra con una frontera limpia, no con un repo aparte. Si el paquete
se estabiliza o se usa en otro proyecto, se extrae a su propio repo sin reescribir nada.

## Decisiones

- **Paquete en el mismo repo** (`packages/ilustrador/`), instalable con `pip install -e`.
- **CLI y MCP son adaptadores finos**: toda la lógica vive en `servicio.py`.
- **Catálogo en `catalogo.toml`**: activos, categorías, aspectos y fondos fuera del código.
- **Sin `sys.exit` en la librería**: excepciones `IlustracionError`.
- **Resultado estructurado**: `ResultadoGeneracion` con originales, revisiones y coste.
- **Revisión ligera automática**: cada generación produce también un JPEG de 768 px.
- **Sin red en tests**: el servicio acepta un cliente falso.

## Estructura

```
JuegoLucia/
  catalogo.toml
  Docu/Ilustraciones/Descripciones/
  Ilustraciones/
  packages/
    ilustrador/
      pyproject.toml
      README.md
      src/ilustrador/
        __init__.py
        errores.py
        catalogo.py
        prompts.py
        cliente.py
        revision.py
        almacen.py
        servicio.py
        mcp.py
      tests/
  scripts/
    generar_ilustraciones.py   # CLI
    preparar_revision.py       # CLI
    mcp_ilustraciones.py       # entry point del MCP
```

## Módulos

| Módulo        | Responsabilidad                                 | No debe saber de       |
| ------------- | ----------------------------------------------- | ---------------------- |
| `errores.py`  | `IlustracionError`                              | nada                   |
| `catalogo.py` | `Proyecto`, `Activo`, `Catalogo`, carga de TOML | HTTP, Pillow           |
| `prompts.py`  | guía de estilo, prompt, referencias             | HTTP, guardar archivos |
| `cliente.py`  | API OpenRouter, errores, respuesta              | rutas del proyecto     |
| `revision.py` | copia ligera con Pillow                         | HTTP, catálogo         |
| `almacen.py`  | versionado `_vNN`, guardar, rutas               | HTTP, prompts          |
| `servicio.py` | orquestación completa                           | argparse, MCP          |
| `mcp.py`      | tools MCP                                       | lógica de negocio      |

## Catálogo

`catalogo.toml` define el proyecto y los activos:

```toml
[proyecto]
descripciones = "Docu/Ilustraciones/Descripciones"
guia_estilo = "Docu/Ilustraciones/Descripciones/Guia_de_estilo_comun.md"
salida = "Ilustraciones"
revision = "Ilustraciones/revision"

[generacion]
modelo = "qwen/qwen-image-2.1-turbo"
timeout = 300
revision_max = 768
revision_calidad = 82

[[activos]]
nombre = "Heroe_Chispita"
categoria = "personaje"
aspecto = "1:1"
fondo = "white"
```

Reglas:

- `categoria`: `personaje`, `objeto` o `escenario`.
- `fondo`: `white`, `magenta` o `none`.
- Si se omite `fondo`, los escenarios usan `none` y el resto `white`.
- Si se omite `aspecto`, los escenarios usan `16:9` y el resto `1:1`.

## Variantes

Una variante es un activo que hereda de otro:

```toml
[[activos]]
nombre = "Heroe_Chispita_sorprendido"
base = "Heroe_Chispita"
descripcion = "Heroe_Chispita_sorprendido.md"
```

- `categoria`, `aspecto` y `fondo` se heredan de la base si no se indican.
- El `.md` de la variante contiene solo el delta (expresión, pose, etc.).
- El servicio compone `base + delta` antes de añadir estilo y fondo.
- La salida se versiona con el nombre de la variante.
- Se detectan bases inexistentes y ciclos de herencia.

## Flujo de generación

1. `servicio.generar_ilustracion(proyecto, catalogo, nombre, ...)`.
2. Compone la descripción del activo (base + delta si es una variante).
3. Extrae el bloque de estilo de la guía común.
4. Compone el prompt con la directriz de fondo.
5. Carga las referencias como data URLs.
6. Llama a OpenRouter.
7. Guarda cada imagen como `<nombre>_vNN.<ext>`.
8. Crea la copia de revisión en `Ilustraciones/revision/<nombre>_vNN.jpg`.
9. Devuelve `ResultadoGeneracion`.

## Tools MCP

- `listar_activos()`: nombre, categoría, aspecto, fondo y versiones existentes.
- `leer_descripcion(nombre)`: texto del `.md`.
- `leer_guia_estilo()`: texto de la guía común.
- `generar_ilustracion(nombre, modelo?, fondo?, aspecto?, seed?, referencias?, n?)`:
  devuelve originales, revisiones, coste y prompt.
- `preparar_revision(nombre?, force?)`: regenera copias ligeras.

## Fases

1. Crear el paquete y el `catalogo.toml`.
2. Refactorizar los dos CLIs para que usen el paquete.
3. Añadir el servidor MCP.
4. Tests con cliente falso.
5. Configurar Zed y probar una generación real.

## Pruebas

- `test_catalogo.py`: carga de TOML, defaults y activo desconocido.
- `test_prompts.py`: composición del prompt y bloque de estilo.
- `test_almacen.py`: versionado y guardado.
- `test_servicio.py`: flujo completo con cliente falso, original + revisión.

## Estado de implementación

- [x] Paquete `packages/ilustrador/` con `pyproject.toml`.
- [x] `catalogo.toml` del juego.
- [x] CLIs refactorizados (`generar_ilustraciones.py`, `preparar_revision.py`).
- [x] Servidor MCP con 5 tools.
- [x] 12 tests con cliente falso.
- [x] Entorno virtual y paquete instalado en modo editable.
- [x] Transporte stdio verificado con el cliente MCP.
- [x] Variantes base + delta (`Heroe_Chispita_sorprendido`).
- [x] Generación real desde el MCP (v04 sorprendido).
- [ ] Configurar el servidor en Zed y probar una generación real.

## Configuración de Zed

El snippet está en `Docu/zed_mcp_config.json`. Se puede pegar en
`~/.config/zed/settings.json` o añadir desde **Settings → AI → MCP Servers →
Add Local Server**. La API key se lee del `.env` del proyecto, así que no hace
falta ponerla en los ajustes de Zed.

```json
{
    "context_servers": {
        "ilustrador": {
            "command": "/home/eduardo/Code/JuegoLucia/packages/ilustrador/.venv/bin/ilustrador-mcp",
            "args": ["--proyecto", "/home/eduardo/Code/JuegoLucia"],
            "env": {}
        }
    }
}
```

## Comandos útiles

```bash
# Tests del paquete
python3 -m unittest discover -s packages/ilustrador/tests -v

# CLI de generacion
python3 scripts/generar_ilustraciones.py Heroe_Chispita

# Copias de revision
python3 scripts/preparar_revision.py

# Servidor MCP (stdio)
packages/ilustrador/.venv/bin/ilustrador-mcp --proyecto .
```

## Pendientes

- Probar VectorCraft para trazar sprites y crear UI vectorial (experimento aparte).
- Publicar el paquete en PyPI si se reutiliza en otro proyecto.
- Añadir más activos al catálogo cuando el juego crezca.

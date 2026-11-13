# Comparación de modelos de imagen en OpenRouter

Documento de apoyo para [`Plan_Animaciones.md`](Plan_Animaciones.md).

- **Fecha de consulta:** 2026-11-12.
- **Fuente:** `https://openrouter.ai/api/v1/images/models` y
  `https://openrouter.ai/api/v1/images/models/<slug>/endpoints`.
- **Objetivo:** elegir el modelo para generar las poses y efectos de la batalla
  con la misma identidad visual que las ilustraciones base.

> Los precios cambian. Antes de un lote grande, vuelve a consultar el endpoint
> de _endpoints_ del modelo elegido.

## Resumen

1. OpenRouter tiene **65 modelos de imagen**, pero **ninguno está especializado
   en sprites o pixel art**. Todos son generalistas.
2. Los modelos especializados en sprites (PixelLab, Retro Diffusion) **no están
   en OpenRouter** y son de **pixel art**, con límites de 512/384 px. No encajan
   con el estilo dibujado a mano ni con el flujo de poses con lienzo cuadrado.
3. **Decisión final:** `qwen/qwen-image-3-pro` para los personajes, conservando
   la **resolución nativa** que devuelva el modelo (768 × 768 o 1024 × 1024).
   Es el que mejor conservó la identidad y el margen en el piloto, devuelve PNG
   y encaja con el pipeline. Nano Banana 2.1 y FLUX.2 Pro quedan como
   alternativas descartadas para esta fase.

## Cómo leer los precios

Todos los precios están en **USD**.

- **`imagen`**: precio fijo por imagen generada.
- **`MP`**: precio por megapíxel. Un lienzo de 1024×1024 son ~1.05 MP.
- **`token`**: precio por token de salida. El coste por imagen es aproximado y
  depende de la resolución y la calidad. La API devuelve el coste real en
  `usage.cost`.
- Algunos modelos cobran además la **imagen de referencia** (Seedream, Qwen,
  Grok). Es un coste pequeño, pero conviene tenerlo en cuenta.
- Los precios son de **salida**; no incluyen reintentos ni imágenes descartadas.

## Tabla principal

Selección de los modelos relevantes para este proyecto; no es el catálogo
completo.

| Modelo (slug)                       | Nombre               | Precio de salida                          | Coste ~22 imágenes      | Resolución | Refs     | Fondo transparente nativo | Veredicto               | Comentario                                                                                              |
| ----------------------------------- | -------------------- | ----------------------------------------- | ----------------------- | ---------- | -------- | ------------------------- | ----------------------- | ------------------------------------------------------------------------------------------------------- |
| `google/gemini-nano-banana-2.1`     | Nano Banana 2.1      | ~$0.04/imagen (token)                     | ~$0.88                  | 1K/2K/4K   | Hasta 14 | No                        | **Piloto**              | Mejor equilibrio calidad/precio/consistencia. Edición fina: conserva personaje, encuadre y escala.      |
| `black-forest-labs/flux.2-pro`      | FLUX.2 Pro           | ~$0.031/imagen a 1024² ($0.03/MP)         | ~$0.68                  | 1 MP+      | Sí       | No                        | **Piloto**              | Muy buena adherencia a la referencia. Comprobar que devuelve PNG; si no, forzar `output_format: "png"`. |
| `qwen/qwen-image-3-pro`             | Qwen Image 3 Pro     | $0.04 (1K) / $0.075 (2K)                  | $0.88 (1K) / $1.65 (2K) | 1K/2K      | Sí       | No                        | **Piloto**              | Menos disruptivo: mismo proveedor y misma API que el modelo actual.                                     |
| `google/gemini-3-pro-image`         | Nano Banana Pro      | ~$0.15/imagen (token)                     | ~$3.30                  | 1K/2K/4K   | Sí       | No                        | Calidad máxima          | Techo de calidad. Usar si el piloto con 2.1 no convence.                                                |
| `bytedance-seed/seedream-5-0-pro`   | Seedream 5.0 Pro     | $0.045/imagen; $0.09 alta resolución      | $0.99 / $1.98 alta res. | 1K/2K      | Sí       | No                        | Alternativa             | Buen equilibrio edición/consistencia. Cobra la referencia ($0.003/imagen).                              |
| `qwen/qwen-image-3`                 | Qwen Image 3         | $0.03/imagen                              | $0.66                   | 1K/2K      | Sí       | No                        | Alternativa             | Upgrade directo y barato del actual.                                                                    |
| `qwen/qwen-image-2.1-turbo`         | Qwen Image 2.1 Turbo | $0.0184/imagen                            | ~$0.40                  | 1K/2K      | Sí       | No                        | **Actual / borradores** | Rápido y barato; el más propenso a deriva. Ideal para explorar, no para la versión final.               |
| `qwen/qwen-image-2.1-pro`           | Qwen Image 2.1 Pro   | $0.046/imagen                             | ~$1.01                  | 1K/2K      | Sí       | No                        | Alternativa             | Más calidad que el turbo, mismo proveedor.                                                              |
| `black-forest-labs/flux.2-klein-4b` | FLUX.2 Klein 4B      | ~$0.015/imagen a 1024² ($0.014/MP)        | ~$0.33                  | 1 MP+      | Sí       | No                        | Económico               | El FLUX más barato; calidad menor.                                                                      |
| `black-forest-labs/flux.2-flex`     | FLUX.2 Flex          | ~$0.063/imagen a 1024² ($0.06/MP)         | ~$1.39                  | 1 MP+      | Sí       | No                        | Intermedio              | Punto medio entre Klein y Pro.                                                                          |
| `bytedance-seed/seedream-5-0-lite`  | Seedream 5.0 Lite    | $0.035/imagen                             | $0.77                   | 1K/2K      | Sí       | No                        | Económico               | Alternativa barata a Seedream Pro.                                                                      |
| `openai/gpt-image-2`                | GPT Image 2          | ~$0.04–0.13/imagen (token, según calidad) | ~$0.88–2.86             | 1K/2K      | Sí       | **Sí**                    | Alternativa             | Buen seguimiento de instrucciones; más lento. Permite fondo transparente nativo.                        |

**Coste ~22 imágenes:** estimación a 1024×1024 (1K), sin reintentos ni
descartes. La decisión final es conservar la **resolución nativa** del modelo;
no se redimensiona. Con Qwen Image 3 Pro el coste por imagen es ~$0.043. Para
los modelos por token se usa la misma estimación de ~1290 tokens/imagen. Para
GPT Image, el coste varía bastante con `quality` (`low`, `medium`, `high`).

El pipeline actual usa **fondo blanco + recorte**, así que la transparencia
nativa no es un requisito; solo es una comodidad si algún día se quiere evitar
el paso de recorte.

## Otros modelos consultados

| Modelo (slug)                        | Precio de salida                               | Coste ~22 imágenes            | Resolución    | Refs      | Comentario                                                       |
| ------------------------------------ | ---------------------------------------------- | ----------------------------- | ------------- | --------- | ---------------------------------------------------------------- |
| `google/gemini-3.1-flash-image`      | ~$0.077/imagen (token)                         | ~$1.69                        | 1K            | Sí        | Nano Banana 2. Generación/edición rápida y consistente.          |
| `google/gemini-3.1-flash-lite-image` | ~$0.039/imagen (token)                         | ~$0.86                        | 1K            | Sí        | Nano Banana 2 Lite. Rápido y barato para explorar.               |
| `openai/gpt-image-1`                 | ~$0.01–0.17/imagen (token, según calidad)      | ~$0.22–3.74                   | 1K/2K         | Sí        | Generación/edición con fondo transparente.                       |
| `openai/gpt-image-1-mini`            | ~$0.01–0.04/imagen (token)                     | ~$0.22–0.88                   | 1K            | Sí        | Versión económica de GPT Image 1.                                |
| `recraft/recraft-v4.1`               | $0.035/imagen                                  | $0.77                         | Ráster/vector | Sí        | Estilo flat/vector. Útil para UI e iconos, no para el personaje. |
| `krea/krea-2-large`                  | $0.06/imagen; $0.065 con referencias de estilo | $1.32; $1.43 con refs         | 1K/2K         | Sí        | Estilo artístico; útil para explorar direcciones visuales.       |
| `sourceful/riverflow-v2.6-pro`       | $0.13/imagen; $0.15 (2K); $0.17 (4K)           | $2.86; $3.30 (2K); $3.74 (4K) | 1K/2K/4K      | Sí        | Alta calidad; caro para 22 imágenes.                             |
| `x-ai/grok-imagine-image-2.0`        | $0.04–0.08/imagen                              | $0.88–1.76                    | 1K/2K         | Sí        | Alternativa; cobra la referencia ($0.01/imagen).                 |
| `minimax/minimax-h3-image`           | ~$0.005/imagen (token)                         | ~$0.11                        | 1K/2K         | Sí        | Muy barato; calidad a validar.                                   |
| `microsoft/mai-image-2.6`            | ~$0.05/imagen (token)                          | ~$1.10                        | 1K/2K         | Sí        | Alternativa de Microsoft; calidad a validar.                     |
| `tencent/hy-image-v3.5-preview`      | ~$0.002/imagen (token)                         | ~$0.04                        | 1K/2K         | Sí        | Muy barato; versión preview.                                     |
| `meta/muse-image`                    | Sin precio publicado                           | —                             | —             | No consta | Sin datos suficientes para recomendarlo.                         |

## Fuera de OpenRouter: especializados en sprites

| Herramienta         | Precio                                         | Resolución                           | Salida                                          | ¿Encaja en JuegoLucia?                                                         |
| ------------------- | ---------------------------------------------- | ------------------------------------ | ----------------------------------------------- | ------------------------------------------------------------------------------ |
| **PixelLab**        | ~$0.008–0.15 por imagen/animación              | 512×512 (Pro); 256×256 (animaciones) | Pixel art, sprite sheets, rotaciones 4/8, VFX   | **No.** Pixel art y 512 px máximo; el juego es ilustración de alta resolución. |
| **Retro Diffusion** | $0.03–0.18 por imagen; animaciones desde $0.10 | 16–384 px                            | Pixel art, animaciones de 4–16 frames, tilesets | **No.** Pixel art y 384 px máximo.                                             |

Ambas tienen API y servidor MCP, pero no aparecen en el catálogo de imágenes de
OpenRouter. Serían la herramienta correcta para un spin-off en pixel art o para
animación frame-by-frame real, no para este plan.

## Recomendación para JuegoLucia

1. **Modelo de producción:** `qwen/qwen-image-3-pro`.
2. **Resolución de personajes:** la **nativa del modelo**. No se envía
   `resolution` ni se redimensiona la imagen; cada generación conserva el
   tamaño que devuelve el proveedor.
3. **Objetos y escenarios:** también conservan la resolución nativa del modelo;
   no se fuerza una resolución distinta.
4. **Borradores:** `qwen/qwen-image-2.1-turbo` sigue disponible para pruebas
   rápidas.
5. **No cambiar** a PixelLab/Retro Diffusion salvo cambio de estilo a pixel art.

### Comandos del piloto

> El piloto A/B ya se ejecutó. La decisión final fue **Qwen Image 3 Pro**,
> conservando la resolución nativa del modelo. Los comandos siguientes quedan
> como registro para reproducirlo.

Atajo para lanzar los tres seguidos:

```bash
bash scripts/piloto_modelos.sh
# o con otro activo/referencia:
bash scripts/piloto_modelos.sh Heroe_Chispita_atacando Ilustraciones/Heroe_Chispita_v01.png
```

O ejecutarlos uno a uno:

```bash
python3 scripts/generar_ilustraciones.py Heroe_Chispita_atacando \
  --ref Ilustraciones/Heroe_Chispita_v01.png \
  --model google/gemini-nano-banana-2.1

python3 scripts/generar_ilustraciones.py Heroe_Chispita_atacando \
  --ref Ilustraciones/Heroe_Chispita_v01.png \
  --model black-forest-labs/flux.2-pro

python3 scripts/generar_ilustraciones.py Heroe_Chispita_atacando \
  --ref Ilustraciones/Heroe_Chispita_v01.png \
  --model qwen/qwen-image-3-pro
```

Cada ejecución crea una versión nueva y su copia en `Ilustraciones/revision/`.
El coste total del piloto es de unos **$0.10–0.20**.

### Criterios de comparación

- Misma identidad: color, crin, cuerno, collar y proporciones.
- Cuerpo y ojos mirando a la derecha.
- Misma escala y línea de suelo.
- Cuerno completo y con margen.
- Fondo blanco limpio, sin sombras.
- Sin texto, números ni marcas.
- Recorte limpio con `recortar_fondos.py`.

### Plantilla de evaluación

Rellena una columna por modelo después de revisar las copias ligeras.

| Criterio                                | Nano Banana 2.1 | FLUX.2 Pro | Qwen Image 3 Pro |
| --------------------------------------- | --------------- | ---------- | ---------------- |
| Identidad (color, crin, cuerno, collar) |                 |            |                  |
| Orientación a la derecha                |                 |            |                  |
| Escala y línea de suelo                 |                 |            |                  |
| Encuadre y margen del cuerno            |                 |            |                  |
| Fondo blanco limpio                     |                 |            |                  |
| Sin texto ni números                    |                 |            |                  |
| Recorte limpio                          |                 |            |                  |
| Veredicto                               |                 |            |                  |

## Cómo actualizar esta tabla

```bash
curl -s https://openrouter.ai/api/v1/images/models
curl -s https://openrouter.ai/api/v1/images/models/<slug>/endpoints
```

El primer endpoint lista los modelos y sus capacidades; el segundo da el precio
definitivo por proveedor. Los precios y los slugs pueden cambiar.

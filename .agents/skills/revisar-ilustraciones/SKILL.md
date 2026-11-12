---
name: revisar-ilustraciones
description: Úsala siempre que el usuario mencione, adjunte o pida revisar una imagen de Ilustraciones/ o un activo del catálogo (Heroe_Chispita, Monstruo_De_Sombras, etc.). Obliga a leer la copia ligera de Ilustraciones/revision/ en vez del PNG original, y a generarla si no existe o está desactualizada.
---

# Revisar ilustraciones sin leer los originales

Los PNG de `Ilustraciones/` son pesados. Leerlos consume el límite de contexto y
puede colgar la conversación. Para revisar cualquier imagen usa **siempre** la
copia ligera de `Ilustraciones/revision/`.

## Regla principal

- **Nunca** leas con `read_file` un original `Ilustraciones/<nombre>_vNN.png`.
- Lee únicamente `Ilustraciones/revision/<nombre>_vNN.jpg`.
- Si la copia ligera no existe, o es más antigua que el original, genérala antes
  de leerla.
- Si de verdad necesitas el original a máxima resolución para juzgar un detalle
  fino, dilo y pide permiso antes de abrirlo.

## Procedimiento

1. Identifica el activo y la versión. Si no sabes qué versiones hay, usa
   `listar_activos()` o `ls Ilustraciones/`.
2. Comprueba si existe `Ilustraciones/revision/<nombre>_vNN.jpg`.
3. Si falta o está desactualizada, genérala con la tool MCP:

    ```
    preparar_revision(nombre="<nombre>")
    ```

    La tool no regenera si la revisión ya es más nueva que el original. Usa
    `force=true` solo si sospechas que el contenido cambió sin actualizar la fecha.

    Alternativa por CLI (si el MCP no está disponible):

    ```bash
    packages/ilustrador/.venv/bin/python scripts/preparar_revision.py <nombre>
    ```

4. Lee solo la copia ligera:

    ```
    read_file Ilustraciones/revision/<nombre>_vNN.jpg
    ```

5. Al terminar, indica en tu respuesta qué versión revisaste.

## Recortes con transparencia

Los recortes viven en `Ilustraciones/recortes/<nombre>_vNN.png` y su copia ligera
es `Ilustraciones/revision/<nombre>_vNN_recorte.jpg`.

- Genéralos con `recortar_fondos(nombre="<nombre>")` o
  `packages/ilustrador/.venv/bin/python scripts/recortar_fondos.py <nombre>`.
- Los recortes se ajustan automáticamente al dibujo: se elimina el espacio
  transparente sobrante, conservando 2 px de respiro por defecto. Usa
  `margen=N` si quieres cambiarlo.
- También se rellena el RGB de los píxeles transparentes con el color opaco más
  cercano (_color bleed_) para evitar halos al filtrar. El alfa no cambia. Usa
  `sangrar=false` para desactivarlo.
- Revisa siempre el `_recorte.jpg`, nunca el PNG recortado.

## Nombres y ajustes

| Elemento             | Ruta                                              |
| -------------------- | ------------------------------------------------- |
| Original             | `Ilustraciones/<nombre>_vNN.png`                  |
| Revisión             | `Ilustraciones/revision/<nombre>_vNN.jpg`         |
| Recorte              | `Ilustraciones/recortes/<nombre>_vNN.png`         |
| Revisión del recorte | `Ilustraciones/revision/<nombre>_vNN_recorte.jpg` |

- La revisión se considera al día si su `mtime` es mayor o igual que el del
  original.
- Tamaño y calidad se configuran en `catalogo.toml` → `[generacion]`
  (`revision_max = 768`, `revision_calidad = 82`).
- `generar_ilustracion` ya devuelve las rutas de las revisiones: úsalas
  directamente en lugar de volver a generarlas.

## Qué no hacer

- No leas varios originales "para comparar versiones": compara las revisiones.
- No uses `Ilustraciones/revision/` como fuente para el juego; es solo para
  revisión.
- No borres ni sobrescribas originales. `Ilustraciones/revision/` está en
  `.gitignore` y se puede regenerar en cualquier momento.

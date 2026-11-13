# Plan de animaciones e ilustraciones de batalla

> **Estado actualizado: 12-11-2026.** En `Ilustraciones/` hay 37 PNG: las siete bases elegidas, 27 poses (nueve por personaje, incluidos `asustado`, `frente` y `derrotado`) y los tres efectos obligatorios. Las copias ligeras de revisión se inspeccionaron; se preservan los recortes ya existentes y se integraron en `juego/assets/` las poses de batalla y los tres efectos. Los retratos `frente` y el efecto opcional `Aura_Concentracion` quedan fuera. Las versiones descartadas están en `Ilustraciones/Borradores/`.
>
> En Godot están conectadas las poses y los efectos con `Tween`; `MonstruoSprite.flip_h` ya está activo. También están implementados el botiquín-calculadora y los diez marcadores editables del mapa. La escena arranca sin errores de script en modo headless; quedan la calibración visual en ejecución y las pruebas de combate completas.

## Objetivo

Completar la batalla con poses coherentes y efectos visuales conectados a sus
señales. El flujo objetivo es:

1. Personajes entran desde las esquinas.
2. Nube de multiplicar entra desde arriba.
3. Personajes se muestran concentrados mientras se piensa la respuesta.
4. El atacante se muestra satisfecho y luego atacando.
5. El defensor reacciona sorprendido y recibe daño.
6. El ganador celebra; el perdedor usa la pose `derrotado` antes de salir.

El plan fija también una **orientación y un encuadre comunes** para evitar saltos
al intercambiar texturas. Las poses `frente` son retratos frontales aparte, no
parte de la orientación canónica de batalla.

---

## 1. Decisiones que hay que fijar antes de generar

### 1.1. Orientación canónica: todos miran a la derecha

Todas las ilustraciones de personajes se generan en **vista lateral de juego**
(tres cuartos) con el **cuerpo y los ojos mirando hacia la derecha**.

- **Chispita** se coloca a la izquierda de la batalla y se usa tal cual.
- **Los monstruos** se colocan a la derecha y deben voltearse horizontalmente
  con `TextureRect.flip_h = true`.
- `TextureRect` admite `flip_h`; no hace falta cambiar los nodos a `Sprite2D` ni
  usar `scale.x = -1`. `MonstruoSprite.flip_h = true` ya está activado en
  `juego/scenes/batalla.tscn`.
- Excepción: las variantes `*_frente` miran al espectador y se reservan para
  retratos, menús o mapa.

Ventajas:

- Una sola orientación para todas las descripciones y referencias.
- Las poses asimétricas (mano en la barbilla, cuerno apuntando, celebración con
  una mano arriba) se pueden reutilizar sin duplicar arte.
- El volteo del enemigo es una propiedad visual, no afecta a `scale`, así que
  no interfiere con las animaciones de celebración que cambian la escala.

> Alternativa descartada: dibujar a los monstruos mirando a la izquierda. Es
> válida, pero obliga a mantener dos criterios de orientación y complica las
> variantes.

**Decisión confirmada:** se adopta esta convención.

### 1.2. Lienzo y escala

Se conserva la **resolución nativa** devuelta por `qwen/qwen-image-3-pro`; no se
fuerza resolución ni se redimensionan los originales. Las 37 imágenes actuales
en `Ilustraciones/` tienen fondo blanco. Los recortes transparentes existentes
se preservaron; las poses de batalla y efectos integrados conservan su lienzo de
1024 × 1024.

La escena usa actualmente un `TextureRect` de 240 × 400 para Chispita y uno de
193 × 329 para el monstruo. Al intercambiar lienzos cuadrados completos, la
escala visible puede variar; hay que calibrarla en Godot después de importar las
imágenes.

| Elemento                       | Estado actual                           |
| ------------------------------ | --------------------------------------- |
| Originales en `Ilustraciones/` | Resolución nativa, fondo blanco         |
| `Ilustraciones/recortes/`      | Recortes existentes, lienzo 1024 × 1024 |
| Escala de los `TextureRect`    | Pendiente de revisión visual en Godot   |

Reglas de composición para todas las imágenes:

- Lienzo cuadrado 1:1, fondo blanco liso durante la generación y transparente
  después del recorte.
- Personaje completo, centrado y con margen amplio alrededor.
- Misma escala, misma línea de suelo y mismo encuadre que la imagen base.
- No recortar cuerno, orejas, patas, cola, manos ni corona.
- En las poses de ataque, dejar margen lateral suficiente para el cuerno o las
  manos extendidas.
- Sin texto, letras, números, signos matemáticos, logotipos ni marcas de agua.

**Decisión confirmada:** se usa el lienzo completo con la resolución nativa
del modelo para los personajes.

### 1.3. Referencias: el campo `base` no envía la imagen

En `catalogo.toml`, `base = "..."` solo sirve para **componer la descripción**
(base + delta). No pasa la imagen base a la API.

Por eso, al generar cada variante hay que pasar explícitamente la imagen de
referencia:

```bash
python3 scripts/generar_ilustraciones.py Heroe_Chispita_atacando \
  --ref Ilustraciones/Heroe_Chispita_v01.png
```

### 1.4. Nombres

Usar el nombre del activo en PascalCase para la descripción y la ilustración, y
minúsculas con guiones bajos para el asset de Godot.

| Descripción / ilustración         | Asset en Godot                        |
| --------------------------------- | ------------------------------------- |
| `Heroe_Chispita_atacando`         | `heroe_chispita_atacando.png`         |
| `Monstruo_De_Sombras_concentrado` | `monstruo_de_sombras_concentrado.png` |
| `Monstruo_Secuaz_celebrando`      | `monstruo_secuaz_celebrando.png`      |

Sufijos de estado acordados:

- `_concentrado`
- `_satisfecho`
- `_atacando`
- `_sorprendido`
- `_herido`
- `_celebrando`
- `_asustado`
- `_derrotado`
- `_frente` (retrato)

---

## 2. Revisión de las descripciones actuales

La revisión de bases ya se realizó y el usuario eligió las versiones que son
ahora la fuente de verdad: `Heroe_Chispita_v01.png`,
`Monstruo_De_Sombras_v01.png` y `Monstruo_Secuaz_v01.png`. Las poses se
engendraron usando explícitamente la base correspondiente como referencia.

Regla común para todas las descripciones:

- Sustituir “mirando hacia la izquierda”, “mirando al frente” o “de frente” por
  **“vista lateral de juego con el cuerpo y los ojos mirando hacia la derecha”**.
- Añadir siempre “misma escala, misma línea de suelo y mismo encuadre que la
  imagen de referencia”.
- Recordar que el juego voltea horizontalmente al enemigo con `flip_h`; la
  ilustración siempre se dibuja hacia la derecha.

### 2.1. Chispita

- La base `Heroe_Chispita_v01.png` está elegida y la descripción de orientación
  existe.
- Están generadas y revisadas visualmente las poses `asustado`, `atacando`,
  `celebrando`, `concentrado`, `derrotado`, `frente`, `herido`, `satisfecho` y
  `sorprendido`. Las poses de batalla están copiadas e integradas; `frente` no se
  usa en la escena.
- Falta comprobar en ejecución que el tamaño y la posición se mantengan al
  intercambiar las texturas.

### 2.2. Monstruo de Sombras

La base elegida es `Monstruo_De_Sombras_v01.png` (antes `v02.png`). Mantiene la
identidad y la paleta de sombra; las variantes de batalla se revisaron en sus
copias ligeras y están integradas. También se generó `Monstruo_De_Sombras_frente`
para retrato, pero no se copia hasta que exista una pantalla que lo use. La
elección del usuario tiene prioridad; no regenerar la base sin aprobar primero
una alternativa. Falta comprobar el encuadre en Godot.

### 2.3. Monstruo Secuaz

La base aprobada es `Monstruo_Secuaz_v01.png` (antes `v03.png`). Se
conservaron las características de secuaz flotante y su paleta. Las nueve poses
previstas se revisaron en sus copias ligeras; las poses de batalla y derrota
están integradas. La vista frontal no se usa en esta escena. Falta comprobar que
el secuaz no cambie de escala al intercambiar texturas en Godot.

### 2.4. Monstruo Chico

`Monstruo_Chico` existe en el catálogo y en las descripciones, pero no se usa en
la batalla. Se deja fuera de este plan salvo que se quiera reutilizar más
adelante.

---

## 3. Inventario de imágenes nuevas

### 3.1. Bases

| Activo                                 | Versión activa      | Estado                                |
| -------------------------------------- | ------------------- | ------------------------------------- |
| `Heroe_Chispita`                       | `v01`               | Elegida                               |
| `Monstruo_De_Sombras`                  | `v01` (antes `v02`) | Elegida; revisar orientación de poses |
| `Monstruo_Secuaz`                      | `v01` (antes `v03`) | Elegida                               |
| `Botiquin_de_ayuda`, fondo, mapa, nube | `v01`               | Elegidas                              |

Las versiones sustituidas se conservaron en `Ilustraciones/Borradores/`.

### 3.2. Poses de batalla

| Estado        | Chispita                     | Monstruo de Sombras               | Monstruo Secuaz               |
| ------------- | ---------------------------- | --------------------------------- | ----------------------------- |
| `asustado`    | `Heroe_Chispita_asustado`    | `Monstruo_De_Sombras_asustado`    | `Monstruo_Secuaz_asustado`    |
| `concentrado` | `Heroe_Chispita_concentrado` | `Monstruo_De_Sombras_concentrado` | `Monstruo_Secuaz_concentrado` |
| `satisfecho`  | `Heroe_Chispita_satisfecho`  | `Monstruo_De_Sombras_satisfecho`  | `Monstruo_Secuaz_satisfecho`  |
| `atacando`    | `Heroe_Chispita_atacando`    | `Monstruo_De_Sombras_atacando`    | `Monstruo_Secuaz_atacando`    |
| `sorprendido` | `Heroe_Chispita_sorprendido` | `Monstruo_De_Sombras_sorprendido` | `Monstruo_Secuaz_sorprendido` |
| `herido`      | `Heroe_Chispita_herido`      | `Monstruo_De_Sombras_herido`      | `Monstruo_Secuaz_herido`      |
| `celebrando`  | `Heroe_Chispita_celebrando`  | `Monstruo_De_Sombras_celebrando`  | `Monstruo_Secuaz_celebrando`  |
| `derrotado`   | `Heroe_Chispita_derrotado`   | `Monstruo_De_Sombras_derrotado`   | `Monstruo_Secuaz_derrotado`   |
| `frente`      | `Heroe_Chispita_frente`      | `Monstruo_De_Sombras_frente`      | `Monstruo_Secuaz_frente`      |

Las 27 poses están generadas como `v01` (nueve por personaje: siete estados,
`derrotado` y `frente`). Los tres efectos obligatorios también están generados.
`Aura_Concentracion` sigue siendo opcional y no se ha generado.

### 3.3. Retratos de frente

Los tres retratos están generados. Se reservan para menús, mapa o pantallas de
victoria; no deben reemplazar las poses laterales de batalla.

| Activo                       | Base                  | Estado         |
| ---------------------------- | --------------------- | -------------- |
| `Heroe_Chispita_frente`      | `Heroe_Chispita`      | `v01` generado |
| `Monstruo_De_Sombras_frente` | `Monstruo_De_Sombras` | `v01` generado |
| `Monstruo_Secuaz_frente`     | `Monstruo_Secuaz`     | `v01` generado |

### 3.4. Efectos de ataque (incluidos en esta fase)

Una sola imagen por efecto, animada por código con `Tween`. Las tres imágenes
obligatorias están generadas como `v01`, revisadas, recortadas, copiadas a
`juego/assets/objetos/` y conectadas en la escena de batalla.

| Activo               | Uso                                                  |
| -------------------- | ---------------------------------------------------- |
| `Ataque_Chispita`    | Haz de magia arcoíris o estrella dorada              |
| `Ataque_Sombra`      | Orbe de humo violeta o zarpazo de sombra             |
| `Impacto`            | Destello o estrella de golpe                         |
| `Aura_Concentracion` | Brillo suave alrededor del personaje mientras piensa |

`Ataque_Chispita`, `Ataque_Sombra` e `Impacto` son obligatorios.
`Aura_Concentracion` es opcional.

---

## 4. Creación de descripciones

### 4.1. Archivos que hay que crear o revisar

Revisar:

- `Docu/Ilustraciones/Descripciones/Heroe_Chispita.md`
- `Docu/Ilustraciones/Descripciones/Heroe_Chispita_asustado.md`
- `Docu/Ilustraciones/Descripciones/Heroe_Chispita_sorprendido.md`
- `Docu/Ilustraciones/Descripciones/Monstruo_De_Sombras.md`
- `Docu/Ilustraciones/Descripciones/Monstruo_Secuaz.md`

Ya están creadas las descripciones de las 27 poses (`asustado`, los seis estados
de batalla, `derrotado` y `frente`) y registradas en `catalogo.toml`. También
existen las descripciones de `Ataque_Chispita`, `Ataque_Sombra`, `Impacto` y
`Aura_Concentracion`. Las seis descripciones `frente` y `derrotado` se añadieron
en la fase posterior y ahora están completas.

### 4.2. Plantilla para una variante

```markdown
# <Personaje> <estado>

**Referencia:** usa como referencia visual la imagen base <Activo_base_vNN.png>.

**Cambio respecto a la referencia:** conserva exactamente el diseño, la paleta,
las proporciones, el grosor del contorno, el encuadre, la escala, la línea de
suelo y la orientación de la referencia. Cambia solo la pose y la expresión.

**Orientación:** cuerpo y ojos mirando hacia la derecha, en vista lateral de
juego. La ilustración siempre se dibuja hacia la derecha; el juego voltea al
enemigo cuando corresponde.

**Pose:** ...

**Expresión:** ...

**No:** no cambies de personaje, no añadas texto ni números, no recortes el
cuerno, las orejas, las patas, la cola, las manos ni la corona, no añadas otros
personajes ni escenario.
```

### 4.3. Notas por estado

- **concentrado**: mientras el jugador piensa. Cuerpo estable, mirada fija al
  contrincante, expresión de concentración. Chispita puede tener una pezuña ligeramente
  levantada y el cuerno con un brillo tenue. Los monstruos pueden observar con
  los brazos cruzados o una mano en la barbilla.
- **satisfecho**: acaba de acertar y va a atacar. Sonrisa confiada, pecho
  ligeramente inflado, mirada segura. No es todavía la pose de ataque.
- **atacando**: pico del ataque.
    - Chispita: cuerpo inclinado hacia la derecha, cuerno apuntando al frente y
      brillando, magia arcoíris alrededor del cuerno.
    - Monstruo de Sombras: manos hacia adelante a la derecha, humo violeta
      concentrado, expresión teatral.
    - Monstruo Secuaz: manos cortas hacia adelante a la derecha, humo violeta,
      expresión pícara.
- **sorprendido**: el ataque viene hacia él. Ojos muy abiertos, boca en O,
  cuerpo que retrocede, orejas/cuerpo alarmados. No debe confundirse con
  `asustado`: aquí es una reacción breve, no un estado de vida baja.
- **herido**: acaba de recibir el golpe. Ojos entrecerrados o uno cerrado, ceño
  fruncido, cuerpo encogido, brazos/patas recogidos. Dolor visible pero sin
  violencia gráfica.
- **celebrando**: victoria.
    - Chispita: levantando las dos patas delanteras, cara de ganadora.
    - Monstruo de Sombras: una mano hacia arriba, cara de satisfacción.
    - Monstruo Secuaz: dos manos arriba, cara de incredulidad por haber ganado.
- **derrotado** (opcional): cuerpo desplomado, mirada cansada, expresión de
  derrota. Se usa justo antes de salir de la pantalla.

### 4.4. Correcciones específicas de los monstruos

En todas las descripciones de los monstruos repetir:

- Sin orejas.
- Sin garras afiladas.
- Sin dientes agresivos.
- Sonrisa pícara, juguetona y teatral.
- Nada terrorífico, agresivo ni violento: es un villano de cuento infantil.

En el Monstruo de Sombras añadir:

- Corona dorada sencilla, con una gema violeta y ligeramente ladeada.
- Mayor tamaño y porte teatral que los secuaces.

En el Monstruo Secuaz añadir:

- Cuerpo pequeño, rechoncho y cómico.
- Mechón rizado de humo violeta brillante.
- Cola de humo vaporosa, sin piernas ni pies.

---

## 5. Catálogo

Añadir en `catalogo.toml` una entrada por variante:

```toml
[[activos]]
nombre = "Heroe_Chispita_atacando"
base = "Heroe_Chispita"
descripcion = "Heroe_Chispita_atacando.md"
```

Para los monstruos:

```toml
[[activos]]
nombre = "Monstruo_De_Sombras_atacando"
base = "Monstruo_De_Sombras"
descripcion = "Monstruo_De_Sombras_atacando.md"

[[activos]]
nombre = "Monstruo_Secuaz_atacando"
base = "Monstruo_Secuaz"
descripcion = "Monstruo_Secuaz_atacando.md"
```

Reglas:

- `categoria`, `aspecto` y `fondo` se heredan de la base.
- El `.md` de la variante contiene solo el delta.
- `base` no envía la imagen; la referencia se pasa con `--ref` o con el
  parámetro `referencias` de la tool MCP.

---

## 6. Creación de las ilustraciones

### 6.1. Prueba piloto y generación

El piloto `Heroe_Chispita_atacando_v01.png` se generó desde
`Heroe_Chispita_v01.png`. También se generaron las 27 poses y los tres efectos
obligatorios con `qwen/qwen-image-3-pro`, pasando referencias explícitas para
las variantes de personaje. Las copias ligeras de todas las imágenes se
revisaron antes de integrar las poses de batalla y los efectos.

### 6.2. Comandos

Generar una variante:

```bash
python3 scripts/generar_ilustraciones.py Heroe_Chispita_atacando \
  --ref Ilustraciones/Heroe_Chispita_v01.png
```

Generar una base de monstruo corregida:

```bash
python3 scripts/generar_ilustraciones.py Monstruo_De_Sombras
```

Si la paleta se desvía, se puede usar la v01 como referencia de paleta, pero el
prompt debe corregir expresamente las garras y los dientes.

Generar una variante de monstruo:

```bash
python3 scripts/generar_ilustraciones.py Monstruo_De_Sombras_atacando \
  --ref Ilustraciones/Monstruo_De_Sombras_v02.png
```

Sustituir `v02` por la versión que se apruebe.

### 6.3. Estado y próximos lotes

1. Bases seleccionadas y normalizadas a `v01`: completado.
2. Piloto `Heroe_Chispita_atacando`: generado.
3. Poses de los tres personajes, incluidos `asustado`, `derrotado` y `frente`:
   generadas como `v01`.
4. Efectos obligatorios `Ataque_Chispita`, `Ataque_Sombra` e `Impacto`:
   generados como `v01`.
5. **Siguiente:** revisar las previsualizaciones de recorte ya existentes, confirmar
   cuáles cumplen el brief y regenerar solo los que necesiten corrección.
6. Copiar únicamente los recortes aprobados a `juego/assets/`, conectar texturas y
   efectos a la escena y validar en Godot.
7. `Aura_Concentracion` queda opcional.

No integrar una ilustración que no haya pasado la revisión visual.

### 6.4. Criterios de revisión

- La imagen es una sola figura completa.
- Misma identidad visual que la base.
- Cuerpo y ojos hacia la derecha.
- Misma escala y línea de suelo.
- Sin texto, números ni marcas.
- Sin elementos terroríficos ni violencia gráfica.
- Fondo blanco liso y limpio para el recorte.
- En los monstruos: sin garras, sin dientes agresivos y sin ceño de enfado.

### 6.5. Resolución y calidad

Recomendación: **no forzar resolución ni redimensionar**.

- El modelo de producción es `qwen/qwen-image-3-pro`.
- Se usa la resolución nativa que devuelva el modelo en cada generación
  (768 × 768 o 1024 × 1024 según el proveedor). El pipeline no envía
  `resolution` salvo que se pida explícitamente con `--resolution`, y no
  reescala la imagen después.
- El piloto de `Heroe_Chispita_atacando` conserva bien la identidad, el
  encuadre y el margen con la salida nativa.
- `revision_max` y `revision_calidad` solo afectan a la copia ligera de revisión,
  no a la generación ni a la calidad del original.
- El cuello de botella real es la latencia del modelo y la revisión humana, no
  el tamaño del PNG.

Para las copias de revisión se puede bajar `revision_max` a 512 si el contexto
o el disco pesan, sin afectar al juego.

---

### 7. Recorte

Los originales generados tienen fondo blanco. Ya hay PNG recortados en
`Ilustraciones/recortes/` y sus copias de revisión sobre tablero en
`Ilustraciones/revision/`. Se revisaron visualmente las copias ligeras antes de
integrarlas; no borrar ni regenerar archivos existentes sin detectar un problema
concreto.

Para el juego se recomienda **no recortar los márgenes**:

```bash
python3 scripts/recortar_fondos.py Heroe_Chispita_atacando --sin-recorte-margenes
```

Resultado:

- `Ilustraciones/recortes/Heroe_Chispita_atacando_v01.png` con el lienzo
  completo y fondo transparente.
- `Ilustraciones/revision/Heroe_Chispita_atacando_v01_recorte.jpg` para revisar
  la transparencia sobre un tablero.

Si aparece un halo del fondo, ajustar:

```bash
python3 scripts/recortar_fondos.py Heroe_Chispita_atacando \
  --sin-recorte-margenes --tolerancia 32 --erosion 2
```

Si se quiere una versión ajustada al contenido solo para revisión, se puede
ejecutar sin `--sin-recorte-margenes`, pero **no se usará esa versión en el
juego**.

Para regenerar un recorte ya existente:

```bash
python3 scripts/recortar_fondos.py Heroe_Chispita_atacando \
  --sin-recorte-margenes --force
```

---

## 8. Copia a `juego/assets/`

**Estado actualizado:** se revisaron visualmente las copias ligeras de todos los
recortes (`Ilustraciones/revision/*_recorte.jpg`); los PNG recortados tienen el
lienzo original de 1024 × 1024. Se copiaron las 23 poses que faltaban (incluido
`derrotado`) y los tres efectos a `juego/assets/`; Chispita asustada ya estaba
allí. Los retratos `frente` se dejan fuera porque la batalla no los usa. El
README enumera los estados y efectos integrados.

Copiar la versión aprobada del recorte al asset del juego, sin el sufijo de
versión y en minúsculas:

```bash
cp Ilustraciones/recortes/Heroe_Chispita_atacando_v01.png \
   juego/assets/personajes/heroe_chispita_atacando.png
```

Mapa de nombres:

| Activo                            | Asset                                                         |
| --------------------------------- | ------------------------------------------------------------- |
| `Heroe_Chispita`                  | `juego/assets/personajes/heroe_chispita.png`                  |
| `Heroe_Chispita_asustado`         | `juego/assets/personajes/heroe_chispita_asustado.png`         |
| `Heroe_Chispita_concentrado`      | `juego/assets/personajes/heroe_chispita_concentrado.png`      |
| `Heroe_Chispita_satisfecho`       | `juego/assets/personajes/heroe_chispita_satisfecho.png`       |
| `Heroe_Chispita_atacando`         | `juego/assets/personajes/heroe_chispita_atacando.png`         |
| `Heroe_Chispita_sorprendido`      | `juego/assets/personajes/heroe_chispita_sorprendido.png`      |
| `Heroe_Chispita_herido`           | `juego/assets/personajes/heroe_chispita_herido.png`           |
| `Heroe_Chispita_celebrando`       | `juego/assets/personajes/heroe_chispita_celebrando.png`       |
| `Heroe_Chispita_derrotado`        | `juego/assets/personajes/heroe_chispita_derrotado.png`        |
| `Monstruo_De_Sombras`             | `juego/assets/personajes/monstruo_de_sombras.png`             |
| `Monstruo_De_Sombras_asustado`    | `juego/assets/personajes/monstruo_de_sombras_asustado.png`    |
| `Monstruo_De_Sombras_concentrado` | `juego/assets/personajes/monstruo_de_sombras_concentrado.png` |
| `Monstruo_De_Sombras_satisfecho`  | `juego/assets/personajes/monstruo_de_sombras_satisfecho.png`  |
| `Monstruo_De_Sombras_atacando`    | `juego/assets/personajes/monstruo_de_sombras_atacando.png`    |
| `Monstruo_De_Sombras_sorprendido` | `juego/assets/personajes/monstruo_de_sombras_sorprendido.png` |
| `Monstruo_De_Sombras_herido`      | `juego/assets/personajes/monstruo_de_sombras_herido.png`      |
| `Monstruo_De_Sombras_celebrando`  | `juego/assets/personajes/monstruo_de_sombras_celebrando.png`  |
| `Monstruo_De_Sombras_derrotado`   | `juego/assets/personajes/monstruo_de_sombras_derrotado.png`   |
| `Monstruo_Secuaz`                 | `juego/assets/personajes/monstruo_secuaz.png`                 |
| `Monstruo_Secuaz_asustado`        | `juego/assets/personajes/monstruo_secuaz_asustado.png`        |
| `Monstruo_Secuaz_concentrado`     | `juego/assets/personajes/monstruo_secuaz_concentrado.png`     |
| `Monstruo_Secuaz_satisfecho`      | `juego/assets/personajes/monstruo_secuaz_satisfecho.png`      |
| `Monstruo_Secuaz_atacando`        | `juego/assets/personajes/monstruo_secuaz_atacando.png`        |
| `Monstruo_Secuaz_sorprendido`     | `juego/assets/personajes/monstruo_secuaz_sorprendido.png`     |
| `Monstruo_Secuaz_herido`          | `juego/assets/personajes/monstruo_secuaz_herido.png`          |
| `Monstruo_Secuaz_celebrando`      | `juego/assets/personajes/monstruo_secuaz_celebrando.png`      |
| `Monstruo_Secuaz_derrotado`       | `juego/assets/personajes/monstruo_secuaz_derrotado.png`       |

Después de copiar, abrir Godot para que reimporte los PNG (o ejecutar una
importación headless). **Hecho:** los PNG se importaron con Godot headless y
`juego/assets/README.md` ya enumera las texturas.

Los tres efectos se guardan en `juego/assets/objetos/` como
`ataque_chispita.png`, `ataque_sombra.png` e `impacto.png`. El retrato opcional
`frente` sigue fuera de `juego/assets/` hasta que se conecte a un menú o ficha.

---

## 9. Cambios en `juego/`

### 9.1. Escena `batalla.tscn`

**Estado actualizado:** la escena conserva los `TextureRect` de 240 × 400 para
Chispita y 193 × 329 para el monstruo; `MonstruoSprite.flip_h` ya está activo.
Se añadieron los nodos de efecto para los dos ataques y el impacto. Falta revisar
a mano en ejecución si los tamaños y las posiciones funcionan bien con todas las
poses.

- Ajustar el tamaño del `TextureRect` de los personajes si el lienzo completo
  cambia el tamaño visual. La primera prueba piloto servirá para calibrar:
    - mantener 240 × 400 con `STRETCH_KEEP_ASPECT_CENTERED`, o
    - usar un cuadrado de 320 × 320 para que el lienzo 1:1 se vea completo.
- Mantener los `pivot_offset` centrados para las animaciones de escala y las
  sacudidas.

### 9.2. `batalla.gd`: estado de texturas

**Estado actualizado:** `batalla.gd` ya carga un mapa de texturas para cada
personaje y estado, cambia las poses desde las señales de batalla y mantiene
`_actualizar_barras()` limitado a las barras. El estado idle de Chispita depende
de su vida; los monstruos recuperan la pose base o herida según su vida.

```gdscript
const TEXTURAS := {
    "heroe": {
        "base": preload("res://assets/personajes/heroe_chispita.png"),
        "asustado": preload("res://assets/personajes/heroe_chispita_asustado.png"),
        "concentrado": preload("res://assets/personajes/heroe_chispita_concentrado.png"),
        "satisfecho": preload("res://assets/personajes/heroe_chispita_satisfecho.png"),
        "atacando": preload("res://assets/personajes/heroe_chispita_atacando.png"),
        "sorprendido": preload("res://assets/personajes/heroe_chispita_sorprendido.png"),
        "herido": preload("res://assets/personajes/heroe_chispita_herido.png"),
        "celebrando": preload("res://assets/personajes/heroe_chispita_celebrando.png"),
    },
    "sombras": { ... },
    "secuaz": { ... },
}
```

Funciones nuevas:

```gdscript
func _poner_pose(lado: String, estado: String) -> void:
    # lado = "heroe" o "enemigo"
    # estado = "base", "concentrado", "atacando", ...
```

- `_poner_pose("heroe", estado)` cambia `_sprite_heroe.texture`.
- `_poner_pose("enemigo", estado)` elige entre `sombras` y `secuaz` según
  `pueblo_id` y cambia `_sprite_monstruo.texture`.
- `_actualizar_barras()` deja de cambiar la textura del héroe; solo actualiza
  las barras. La textura de idle se decide en `_poner_pose_idle()`:
    - Chispita: `asustado` si `vida <= 30`, si no `base`.
    - Monstruos: `base` o `herido` según el momento.

### 9.3. Secuencia de señales

- `pregunta_changed`:
    - `_poner_pose("heroe", "concentrado")`
    - `_poner_pose("enemigo", "concentrado")`
- `respuesta_changed`:
    - Atacante: `satisfecho` durante ~0.2 s y después `atacando`.
    - Defensor: `sorprendido` mientras el atacante se lanza.
    - Después de `_batalla.aplicar_dano()`: defensor `herido`.
    - Después de la pausa: `_poner_pose_idle()` para ambos.
- `ganador_changed`:
    - Perdedor: `derrotado` si existe; si no, `herido`. Después sale de la
      pantalla.
    - Ganador: `celebrando` al llegar al centro.
- La nube y las barras mantienen su flujo actual. El botiquín-calculadora y sus animaciones se detallan en 9.6.

### 9.4. Efectos incluidos

Las imágenes `Ataque_Chispita_v01.png`, `Ataque_Sombra_v01.png` e
`Impacto_v01.png` están recortadas, copiadas y conectadas a nodos `TextureRect`.
Los ataques viajan entre personajes con `Tween`; el impacto aparece al aplicar
daño. Falta comprobar visualmente su tamaño y sincronización en ejecución.

- Los nodos `TextureRect` `AtaqueHeroe`, `AtaqueEnemigo` e `Impacto` ya están en
  `batalla.tscn`.
- Los ataques aparecen, avanzan hacia el contrincante y se desvanecen con `Tween`;
  el impacto se reproduce al aplicar el daño.
- Una sola imagen por efecto es suficiente; no se genera una secuencia de frames.

### 9.5. Mapa

`mapa.tscn` contiene diez botones independientes, cada uno con su imagen y el
nombre del pueblo. Sus posiciones iniciales son provisionales y se ajustan a mano
en el editor sobre las casas; los nueve primeros usan el icono del secuaz y el
décimo el Monstruo de Sombras. Al liberar un pueblo, el botón queda deshabilitado
y su imagen se oculta. Pulsar cualquier pueblo ocupado solicita la batalla con
su `pueblo_id`.

Los retratos `*_frente` siguen pendientes de copiar y conectar al mapa o a los
menús; no son necesarios para estos marcadores.

### 9.6. Botiquín-calculadora

El botiquín se abre solo si está disponible. Al abrirlo, `Batalla.pregunta` se
suspende (queda en `null`), se ocultan la nube y las opciones, y el botón con la
ilustración crece y se desplaza al centro. Sobre la pantalla ilustrada aparecen
la suma con `=` y un teclado de los dígitos 0–9, `OK` y `Borrar`.

- Cada dígito se concatena a la respuesta mostrada en la pantalla.
- `OK` devuelve el botiquín a su tamaño y esquina iniciales. Solo una suma
  correcta cura hasta 30 puntos y consume el botiquín; una incorrecta no daña a
  Chispita y permite volver a intentarlo.
- `Borrar` vacía la respuesta y cierra el botiquín sin consumirlo.
- Al cerrarlo se restaura la misma pregunta suspendida y vuelve a aparecer la
  nube. Chispita recupera la pose `concentrado`; al restaurar la pregunta, ambos
  personajes vuelven a esa pose.

---

## 10. Validación

### 10.1. Validación de imágenes

- [ ] Una sola figura completa por imagen.
- [ ] Cuerpo y ojos hacia la derecha.
- [ ] Misma escala y línea de suelo que la referencia.
- [ ] Sin texto, números ni marcas.
- [ ] Sin garras, dientes agresivos ni ceño de enfado en los monstruos.
- [ ] Fondo blanco liso en el original y transparencia limpia en el recorte.
- [ ] Cuerno, orejas, patas, cola, manos y corona completos.

### 10.2. Validación en Godot

- [x] `godot --headless --path juego --quit-after 180 res://scenes/batalla.tscn`
      arranca sin errores de script.
- [ ] El enemigo se ve volteado y mira a Chispita.
- [ ] Al cambiar de pose no hay saltos de posición ni de escala.
- [ ] La secuencia concentrado → satisfecho → atacando → sorprendido → herido
      se reproduce en orden.
- [ ] La celebración del ganador y la salida del perdedor funcionan.
- [ ] Las barras de vida siguen actualizándose.
- [ ] El botiquín anima al centro, muestra `suma = respuesta`, acepta dígitos y
      `OK`/`Borrar`, y restaura la misma nube al cerrarse.
- [ ] Al resolver correctamente el botiquín, Chispita recupera vida hasta el
      máximo y el objeto queda consumido; una respuesta incorrecta no cura.
- [ ] Los diez botones del mapa inician su pueblo y ocultan el icono al liberarlo.
- [ ] Simulación headless de victoria y derrota (como la usada para validar la
      lógica de la batalla).

---

## 11. Riesgos y mitigaciones

| Riesgo                                                     | Mitigación                                                                                    |
| ---------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| La IA cambia el personaje entre poses                      | Usar siempre la base aprobada como `--ref` y revisar cada lote                                |
| El personaje cambia de tamaño o se desplaza                | Mantener el lienzo completo, la misma línea de suelo y la misma escala; calibrar en el piloto |
| Las poses no respetan la orientación lateral de la batalla | Revisar las variantes contra las bases v01 aprobadas antes de recortar e integrar             |
| El jefe se ve más pequeño que el secuaz                    | Usar el lienzo completo y comprobar la jerarquía visual en la escena                          |
| Demasiadas imágenes y coste alto                           | Piloto completado; lotes de `n=1`; revisar antes de regenerar                                 |
| El volteo del enemigo afecta a las animaciones             | Usar `TextureRect.flip_h`, que no toca `scale` ni `position`                                  |
| El recorte deja halos                                      | Ajustar `--tolerancia`, `--erosion` o `--sangrado`                                            |

---

## 12. Decisiones confirmadas y pendientes

Confirmadas:

1. Las bases activas son las siete imágenes elegidas y normalizadas a `v01`.
2. Las variantes de batalla se diseñan mirando a la derecha; `frente` es una
   orientación de retrato separada. `MonstruoSprite.flip_h` está activado en la
   escena para que el enemigo mire hacia Chispita.
3. El modelo de producción es `qwen/qwen-image-3-pro`, con resolución nativa y
   referencia explícita de la base para cada pose.
4. Están generadas 27 poses (`siete estados + derrotado + frente` para cada
   personaje) y los tres efectos obligatorios. `Aura_Concentracion` sigue siendo
   opcional.
5. Hay PNG en `Ilustraciones/recortes/` y revisiones `_recorte.jpg` en
   `Ilustraciones/revision/`, pese a la instrucción anterior de mantenerlas
   vacías. Se preservan estos archivos existentes; no vaciar las carpetas sin
   confirmación.

Pendiente:

- Revisar la escena en ejecución y probar ataques, victoria/derrota y botiquín;
  calibrar tamaños, posiciones y sincronización de poses/efectos.

---

## 13. Checklist de ejecución

- [x] Revisar y elegir las siete bases activas; normalizarlas a `v01`.
- [x] Crear las descripciones y entradas del catálogo para los estados.
- [x] Generar las 27 poses de los tres personajes con referencias explícitas.
- [x] Generar `Heroe_Chispita_frente` y las tres poses `derrotado`.
- [x] Generar los efectos obligatorios `Ataque_Chispita`, `Ataque_Sombra` e `Impacto`.
- [x] Revisar visualmente las copias de revisión de las poses y los efectos; corregir
      solo resultados que no cumplan el brief.
- [x] Confirmar que los recortes conservan el lienzo 1024 × 1024, sin eliminar márgenes.
- [x] Copiar las poses de batalla y efectos a `juego/assets/` y actualizar el README.
- [x] Activar `flip_h = true` en `batalla.tscn`.
- [x] Implementar el mapa de texturas y conectar los estados a las señales en
      `batalla.gd`.
- [x] Integrar los efectos con `Tween`.
- [ ] Calibrar tamaños/posiciones y probar el flujo de combate, victoria/derrota
      y botiquín en ejecución.
- [x] Implementar la interfaz-calculadora del botiquín y suspender/restaurar la
      pregunta de batalla al abrir/cerrar.
- [x] Crear diez marcadores de mapa ajustables a mano; ocultar el icono al liberar
      el pueblo y mantener la transición a batalla.
- [ ] Decidir si se genera el efecto opcional `Aura_Concentracion`.

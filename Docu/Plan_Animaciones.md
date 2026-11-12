# Plan de animaciones e ilustraciones de batalla

## Objetivo

Dotar a la batalla de una colección coherente de poses y efectos para que el
flujo de señales ya implementado se vea animado:

1. Personajes entrando desde las esquinas.
2. Nube de multiplicar entrando desde arriba.
3. Personaje concentrado mientras se piensa la respuesta.
4. Personaje satisfecho al acertar.
5. Ataque del ganador de la pregunta.
6. Sorpresa y daño del perdedor.
7. Celebración del ganador.
8. Derrota del perdedor (queda para una fase posterior).

El plan también fija una **orientación y un encuadre comunes** para que los
sprites no salten ni cambien de escala al intercambiar texturas.

---

## 1. Decisiones que hay que fijar antes de generar

### 1.1. Orientación canónica: todos miran a la derecha

Todas las ilustraciones de personajes se generan en **vista lateral de juego**
(tres cuartos) con el **cuerpo y los ojos mirando hacia la derecha**.

- **Chispita** se coloca a la izquierda de la batalla y se usa tal cual.
- **Los monstruos** se colocan a la derecha y se **voltean horizontalmente** en
  Godot con `TextureRect.flip_h = true`.
- Verificado: `TextureRect` de Godot 4.7 sí tiene `flip_h`; no hace falta
  cambiar los nodos a `Sprite2D` ni usar `scale.x = -1`.

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

Para el juego se conserva el **lienzo cuadrado original de 1024 × 1024 px con
fondo transparente**, sin recortar los márgenes del dibujo.

Motivo: el recorte ajustado al contenido cambia el tamaño y el aspecto de cada
pose. En la escena actual todos los personajes se dibujan en un `TextureRect`
de 240 × 400 y, al cambiar de textura, el personaje puede saltar o cambiar de
tamaño. Además, ahora mismo la jerarquía visual está invertida:

| Personaje           | Recorte actual | Altura aproximada en el `TextureRect` 240 × 400 |
| ------------------- | -------------- | ----------------------------------------------- |
| Chispita            | 600 × 868      | ~347 px                                         |
| Chispita asustado   | 606 × 858      | ~340 px                                         |
| Monstruo de Sombras | 889 × 988      | ~267 px                                         |
| Monstruo Secuaz     | 511 × 865      | ~400 px                                         |

El jefe final se ve más pequeño que Chispita y el secuaz se ve más grande que
el jefe. Con el lienzo completo se conserva la proporción real de cada dibujo
dentro del encuadre y el jefe puede verse claramente más grande.

Reglas de composición para todas las imágenes:

- Lienzo cuadrado 1:1, fondo blanco liso durante la generación y transparente
  después del recorte.
- Personaje completo, centrado y con margen amplio alrededor.
- Misma escala, misma línea de suelo y mismo encuadre que la imagen base.
- No recortar cuerno, orejas, patas, cola, manos ni corona.
- En las poses de ataque, dejar margen lateral suficiente para el cuerno o las
  manos extendidas.
- Sin texto, letras, números, signos matemáticos, logotipos ni marcas de agua.

**Decisión confirmada:** se usa el lienzo completo de 1024 × 1024 para los
personajes.

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
- `_derrotado` (opcional)
- `_frente` (retrato opcional)

---

## 2. Revisión de las descripciones actuales

Antes de generar variantes hay que corregir las bases. Si no, el error se
repite en todas las poses.

Regla común para todas las descripciones:

- Sustituir “mirando hacia la izquierda”, “mirando al frente” o “de frente” por
  **“vista lateral de juego con el cuerpo y los ojos mirando hacia la derecha”**.
- Añadir siempre “misma escala, misma línea de suelo y mismo encuadre que la
  imagen de referencia”.
- Recordar que el juego voltea horizontalmente al enemigo con `flip_h`; la
  ilustración siempre se dibuja hacia la derecha.

### 2.1. Chispita

- `Heroe_Chispita.md`: la imagen v01 ya mira a la derecha. Se conserva.
  Actualizar la descripción para fijar explícitamente:
    - cuerpo y ojos hacia la derecha;
    - misma línea de suelo y encuadre;
    - vista lateral de juego.
- `Heroe_Chispita_asustado.md`: la imagen v01 también mira a la derecha. Se
  conserva. Añadir la misma nota de orientación y encuadre.
- `Heroe_Chispita_sorprendido.md`: la descripción existe, pero no hay imagen.
  Revisarla y generarla con la nueva convención.

### 2.2. Monstruo de Sombras

La imagen v01 no cumple del todo el brief:

- Está mirando al frente, no de lado hacia el contrincante.
- Tiene **garras afiladas**, y la descripción dice expresamente que no las
  tiene.
- La sonrisa es muy dentada y el gesto resulta más agresivo que teatral.
- La corona es más recargada que la “corona dorada sencilla” descrita.

Acción: regenerar como `Monstruo_De_Sombras_v02` con:

- vista lateral de juego mirando a la derecha;
- silueta de humo redondeada y compacta;
- sin orejas, sin garras afiladas y sin dientes agresivos;
- sonrisa pícara y teatral, nunca terrorífica;
- corona dorada sencilla con una gema violeta, ligeramente ladeada;
- paleta carbón, azul noche y violeta luminoso.

La v01 se conserva como historial y como posible referencia de paleta, pero la
v02 será la base aprobada para las variantes.

### 2.3. Monstruo Secuaz

La imagen v01 tampoco cumple del todo:

- Está de costado, pero mirando al frente.
- Tiene cejas de enfado y colmillos, y la descripción pide una expresión
  juguetona y pícara, nunca enfadada.
- Su violeta es mucho más brillante que el carbón del jefe; deben parecer de la
  misma familia.

Acción: regenerar como `Monstruo_Secuaz_v02` con:

- vista lateral de juego mirando a la derecha;
- cuerpo de gota rechoncho, sin orejas, sin piernas y con cola de humo;
- cejas arqueadas y sonrisa juguetona, sin ceño de enfado;
- colmillos simpáticos, no agresivos;
- mechón rizado violeta brillante;
- paleta más cercana al carbón y azul noche del jefe, con acentos violeta.

### 2.4. Monstruo Chico

`Monstruo_Chico` existe en el catálogo y en las descripciones, pero no se usa en
la batalla. Se deja fuera de este plan salvo que se quiera reutilizar más
adelante.

---

## 3. Inventario de imágenes nuevas

### 3.1. Bases

| Activo                    | Acción                             | Prioridad |
| ------------------------- | ---------------------------------- | --------- |
| `Heroe_Chispita`          | Conservar v01; revisar descripción | —         |
| `Heroe_Chispita_asustado` | Conservar v01; revisar descripción | —         |
| `Monstruo_De_Sombras`     | Regenerar v02                      | Alta      |
| `Monstruo_Secuaz`         | Regenerar v02                      | Alta      |

### 3.2. Poses de batalla

| Estado                 | Chispita                     | Monstruo de Sombras               | Monstruo Secuaz               |
| ---------------------- | ---------------------------- | --------------------------------- | ----------------------------- |
| `concentrado`          | `Heroe_Chispita_concentrado` | `Monstruo_De_Sombras_concentrado` | `Monstruo_Secuaz_concentrado` |
| `satisfecho`           | `Heroe_Chispita_satisfecho`  | `Monstruo_De_Sombras_satisfecho`  | `Monstruo_Secuaz_satisfecho`  |
| `atacando`             | `Heroe_Chispita_atacando`    | `Monstruo_De_Sombras_atacando`    | `Monstruo_Secuaz_atacando`    |
| `sorprendido`          | `Heroe_Chispita_sorprendido` | `Monstruo_De_Sombras_sorprendido` | `Monstruo_Secuaz_sorprendido` |
| `herido`               | `Heroe_Chispita_herido`      | `Monstruo_De_Sombras_herido`      | `Monstruo_Secuaz_herido`      |
| `celebrando`           | `Heroe_Chispita_celebrando`  | `Monstruo_De_Sombras_celebrando`  | `Monstruo_Secuaz_celebrando`  |
| `derrotado` (opcional) | `Heroe_Chispita_derrotado`   | `Monstruo_De_Sombras_derrotado`   | `Monstruo_Secuaz_derrotado`   |

Total de esta fase: 18 poses (6 estados × 3 personajes) + 4 efectos = 22
imágenes. Las 3 poses de derrota y los retratos de frente quedan para una fase
posterior.

> `asustado` se mantiene solo para Chispita como idle de vida baja. Los
> monstruos pueden usar `herido` mientras esperan la siguiente pregunta.

### 3.3. Retratos de frente (fase posterior)

Para menús, mapa o pantallas de victoria. No se usan en la batalla y quedan
fuera de esta fase.

| Activo                       | Base                  | Uso             |
| ---------------------------- | --------------------- | --------------- |
| `Heroe_Chispita_frente`      | `Heroe_Chispita`      | Retrato frontal |
| `Monstruo_De_Sombras_frente` | `Monstruo_De_Sombras` | Retrato frontal |
| `Monstruo_Secuaz_frente`     | `Monstruo_Secuaz`     | Retrato frontal |

### 3.4. Efectos de ataque (incluidos en esta fase)

Una sola imagen por efecto, animada por código con `Tween`. Se generan en esta
fase:

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

Crear, para cada personaje y estado de la matriz:

- `Heroe_Chispita_concentrado.md`
- `Heroe_Chispita_satisfecho.md`
- `Heroe_Chispita_atacando.md`
- `Heroe_Chispita_herido.md`
- `Heroe_Chispita_celebrando.md`
- `Monstruo_De_Sombras_*.md`
- `Monstruo_Secuaz_*.md`

Crear en esta fase, para los efectos:

- `Ataque_Chispita.md`
- `Ataque_Sombra.md`
- `Impacto.md`
- `Aura_Concentracion.md` (opcional)

Crear en la fase posterior:

- `*_derrotado.md`
- `*_frente.md`

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

### 6.1. Prueba piloto obligatoria

Antes de generar el lote completo:

1. Generar `Heroe_Chispita_atacando` usando `Heroe_Chispita_v01.png` como
   referencia.
2. Revisar la copia ligera `Ilustraciones/revision/Heroe_Chispita_atacando_v01.jpg`.
3. Comprobar:
    - orientación hacia la derecha;
    - mismo personaje, colores y proporciones;
    - mismo tamaño y línea de suelo;
    - cuerno completo y con margen;
    - sin texto ni números.
4. Si el resultado convence, continuar. Si no, ajustar la descripción o la
   referencia y repetir solo esa imagen.

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

### 6.3. Lotes recomendados

1. Bases corregidas: `Monstruo_De_Sombras`, `Monstruo_Secuaz`.
2. Piloto: `Heroe_Chispita_atacando`.
3. Chispita: `concentrado`, `satisfecho`, `sorprendido`, `herido`,
   `celebrando`.
4. Monstruo de Sombras: los seis estados.
5. Monstruo Secuaz: los seis estados.
6. Efectos: `Ataque_Chispita`, `Ataque_Sombra`, `Impacto` y, si se aprueba,
   `Aura_Concentracion`.
7. Fase posterior: `derrotado` y retratos de frente.

Revisar cada lote antes de pasar al siguiente. No generar las 22 imágenes de
golpe sin haber aprobado el piloto.

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

Recomendación: **no bajar la resolución de los personajes**.

- El modelo `qwen/qwen-image-2.1-turbo` ya es una variante rápida.
- El endpoint rechaza `resolution` combinado con `aspect_ratio`; el pipeline
  siempre envía `aspect_ratio` desde el catálogo. Usar `--resolution` exigiría
  tocar el cliente y perder el control del aspecto 1:1.
- `revision_max` y `revision_calidad` solo afectan a la copia ligera de revisión,
  no a la generación ni a la calidad del original.
- El cuello de botella real es la latencia del modelo y la revisión humana, no
  el tamaño del PNG. Bajar de 2K a 1K ahorraría poco y añadiría riesgo de
  inconsistencias.

Si se quiere medir, se puede hacer una prueba con el piloto y comparar tiempos,
pero la decisión por defecto es mantener la resolución actual. Para las copias
de revisión se puede bajar `revision_max` a 512 si el contexto o el disco pesan,
sin afectar al juego.

---

## 7. Recorte

Los originales generados tienen fondo blanco. El recorte convierte ese fondo en
transparencia y guarda el PNG en `Ilustraciones/recortes/`.

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
| `Monstruo_De_Sombras`             | `juego/assets/personajes/monstruo_de_sombras.png`             |
| `Monstruo_De_Sombras_concentrado` | `juego/assets/personajes/monstruo_de_sombras_concentrado.png` |
| `Monstruo_De_Sombras_satisfecho`  | `juego/assets/personajes/monstruo_de_sombras_satisfecho.png`  |
| `Monstruo_De_Sombras_atacando`    | `juego/assets/personajes/monstruo_de_sombras_atacando.png`    |
| `Monstruo_De_Sombras_sorprendido` | `juego/assets/personajes/monstruo_de_sombras_sorprendido.png` |
| `Monstruo_De_Sombras_herido`      | `juego/assets/personajes/monstruo_de_sombras_herido.png`      |
| `Monstruo_De_Sombras_celebrando`  | `juego/assets/personajes/monstruo_de_sombras_celebrando.png`  |
| `Monstruo_Secuaz`                 | `juego/assets/personajes/monstruo_secuaz.png`                 |
| `Monstruo_Secuaz_concentrado`     | `juego/assets/personajes/monstruo_secuaz_concentrado.png`     |
| `Monstruo_Secuaz_satisfecho`      | `juego/assets/personajes/monstruo_secuaz_satisfecho.png`      |
| `Monstruo_Secuaz_atacando`        | `juego/assets/personajes/monstruo_secuaz_atacando.png`        |
| `Monstruo_Secuaz_sorprendido`     | `juego/assets/personajes/monstruo_secuaz_sorprendido.png`     |
| `Monstruo_Secuaz_herido`          | `juego/assets/personajes/monstruo_secuaz_herido.png`          |
| `Monstruo_Secuaz_celebrando`      | `juego/assets/personajes/monstruo_secuaz_celebrando.png`      |

Después de copiar, abrir Godot para que reimporte los PNG (o ejecutar una
importación headless). Actualizar `juego/assets/README.md` con la lista de
nombres nuevos.

Para las imágenes opcionales (`derrotado`, `frente` y efectos), seguir el mismo
patrón: `juego/assets/personajes/<nombre_en_minusculas>.png` para los retratos y
`juego/assets/objetos/<nombre_en_minusculas>.png` para los efectos.

---

## 9. Cambios en `juego/`

### 9.1. Escena `batalla.tscn`

- Activar `flip_h = true` en `MonstruoSprite`, porque todas las ilustraciones
  miran a la derecha y el enemigo está a la derecha.
- Ajustar el tamaño del `TextureRect` de los personajes si el lienzo completo
  cambia el tamaño visual. La primera prueba piloto servirá para calibrar:
    - mantener 240 × 400 con `STRETCH_KEEP_ASPECT_CENTERED`, o
    - usar un cuadrado de 320 × 320 para que el lienzo 1:1 se vea completo.
- Mantener los `pivot_offset` centrados para las animaciones de escala y las
  sacudidas.

### 9.2. `batalla.gd`: estado de texturas

Añadir un mapa de texturas por personaje y estado:

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
- La nube, las barras, el botiquín y los tiempos actuales se mantienen.

### 9.4. Efectos incluidos

Los efectos de ataque e impacto se integran en esta fase:

- Añadir nodos `TextureRect` para `AtaqueHeroe`, `AtaqueEnemigo` e `Impacto`.
- Animar con `Tween`: aparecer, avanzar hacia el contrincante, escalar, rotar y
  desvanecerse.
- El impacto se reproduce en el momento de `aplicar_dano()`.
- No es necesario generar una secuencia de frames; una sola imagen por efecto
  es suficiente.

### 9.5. Mapa

`mapa.gd` usa las texturas base de los monstruos. Si las nuevas bases miran a la
derecha, los iconos del mapa también mirarán a la derecha. Es aceptable. Si se
generan los retratos `*_frente`, se pueden usar en el mapa o en menús para que
los personajes miren al espectador.

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

- [ ] `godot --headless --path juego --quit-after 180 res://scenes/batalla.tscn`
      arranca sin errores de script.
- [ ] El enemigo se ve volteado y mira a Chispita.
- [ ] Al cambiar de pose no hay saltos de posición ni de escala.
- [ ] La secuencia concentrado → satisfecho → atacando → sorprendido → herido
      se reproduce en orden.
- [ ] La celebración del ganador y la salida del perdedor funcionan.
- [ ] Las barras de vida siguen actualizándose.
- [ ] El botiquín sigue funcionando.
- [ ] Simulación headless de victoria y derrota (como la usada para validar la
      lógica de la batalla).

---

## 11. Riesgos y mitigaciones

| Riesgo                                               | Mitigación                                                                                    |
| ---------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| La IA cambia el personaje entre poses                | Usar siempre la base aprobada como `--ref` y revisar cada lote                                |
| El personaje cambia de tamaño o se desplaza          | Mantener el lienzo completo, la misma línea de suelo y la misma escala; calibrar en el piloto |
| Los monstruos siguen saliendo con garras o enfadados | Corregir las bases v02 antes de generar variantes y repetir las descripciones en cada delta   |
| El jefe se ve más pequeño que el secuaz              | Usar el lienzo completo y comprobar la jerarquía visual en la escena                          |
| Demasiadas imágenes y coste alto                     | Piloto, lotes pequeños, `n=1`, opcionales al final                                            |
| El volteo del enemigo afecta a las animaciones       | Usar `TextureRect.flip_h`, que no toca `scale` ni `position`                                  |
| El recorte deja halos                                | Ajustar `--tolerancia`, `--erosion` o `--sangrado`                                            |

---

## 12. Decisiones confirmadas y pendientes

Confirmadas:

1. Todos los personajes miran a la derecha y el enemigo se voltea con `flip_h`.
2. Se usa el lienzo completo de 1024 × 1024 sin recorte de márgenes.
3. Los efectos `Ataque_Chispita`, `Ataque_Sombra` e `Impacto` se incluyen en
   esta fase. `Aura_Concentracion` es opcional.
4. `derrotado` y los retratos de frente quedan para una fase posterior.
5. Se mantiene la resolución de generación actual; no se baja para acelerar.

Pendiente:

- Calibrar el tamaño visual de los sprites en la escena después del piloto.

---

## 13. Checklist de ejecución

- [ ] Revisar las descripciones base y fijar la orientación a la derecha.
- [ ] Regenerar `Monstruo_De_Sombras` v02 sin garras ni gesto agresivo.
- [ ] Regenerar `Monstruo_Secuaz` v02 con expresión juguetona.
- [ ] Generar el piloto `Heroe_Chispita_atacando` y aprobarlo.
- [ ] Crear las descripciones de las 18 variantes.
- [ ] Añadir las entradas al `catalogo.toml`.
- [ ] Generar las variantes por lotes y revisar las copias ligeras.
- [ ] Generar los efectos `Ataque_Chispita`, `Ataque_Sombra` e `Impacto`.
- [ ] Recortar con `--sin-recorte-margenes`.
- [ ] Copiar los recortes aprobados a `juego/assets/personajes/`.
- [ ] Añadir `flip_h = true` al monstruo en `batalla.tscn`.
- [ ] Implementar `_poner_pose()` y la secuencia de estados en `batalla.gd`.
- [ ] Ajustar el tamaño de los `TextureRect` si hace falta.
- [ ] Validar en Godot y con la simulación headless.
- [ ] Actualizar `juego/assets/README.md`.
- [ ] Dejar `derrotado` y los retratos de frente para la fase posterior.

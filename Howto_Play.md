# Cómo jugar a Chispita y las Tablas Mágicas

Guía rápida para empezar a jugar, entender cada pantalla y saber qué hace
cada botón. Al final tienes un resumen de controles y algunos trucos para las
tablas de multiplicar.

## Antes de empezar

- **En Android:** instala el archivo `juego/JuegoChispita.apk` y abre
  _Chispita y las Tablas Mágicas_.
- **En ordenador:** abre la carpeta `juego/` con Godot 4.7 o superior y pulsa
  **F5** (o el botón de reproducir) para iniciar el juego.
- El progreso se guarda automáticamente, así que puedes cerrar el juego y
  continuar más tarde donde lo dejaste.

## 1. La introducción

![Cómic de introducción con Chispita y el Monstruo de Sombras](Ilustraciones/screenshots/01_introducción.png)

Al empezar se muestra un pequeño cómic de tres viñetas:

1. Chispita, un pony pacífico pero valiente, recoge fresas en los valles del
   **Reino Unicornio**.
2. Aparece el **Monstruo de Sombras** y le dice que el reino ahora le
   pertenece.
3. Chispita decide liberar el reino con su magia y su dominio de las
   matemáticas.

Pulsa **Continuar** para ir al mapa.

## 2. El mapa del reino

![Mapa con los diez pueblos, sus monstruos y el botón de opciones](Ilustraciones/screenshots/02_mapa.png)

El mapa muestra los **diez pueblos** unidos por un camino. Sobre cada pueblo
hay un monstruo y una etiqueta:

- **Conquistado:** el pueblo sigue cubierto por la oscuridad y puedes entrar
  a combatir.
- **Liberado:** ya has derrotado a su monstruo. El botón queda desactivado y
  el pueblo no vuelve a jugarse.

Cada pueblo repasa una tabla de multiplicar: el **Pueblo 1** trabaja la tabla
del 1, el **Pueblo 2** la del 2, y así hasta el **Pueblo 10**, donde espera el
propio **Monstruo de Sombras**. Los otros nueve pueblos están defendidos por
sus secuaces.

Puedes entrar en cualquier pueblo que siga conquistado. Lo más cómodo es ir
en orden del 1 al 10, porque cada uno repasa una tabla distinta.

En la esquina superior izquierda está el botón de **opciones** (la rueda
dentada). Lo explico al final.

En la esquina inferior derecha está el botón de **salir** del juego. Al pulsarlo
aparece la pregunta **¿Salir del juego?** con los botones **Sí** y **No**: solo
si pulsas **Sí** se cierra la aplicación.

## 3. La batalla

![Pantalla de batalla con las barras de vida, la nube de preguntas y las tres opciones](Ilustraciones/screenshots/03_batalla.png)

Al entrar en un pueblo empieza el combate:

- **Arriba:** dos barras de vida. A la izquierda la de Chispita y a la derecha
  la del monstruo. Ambos empiezan con **100 / 100**.
- **Centro:** una nube baja con una multiplicación de la tabla del pueblo y
  **tres opciones**. Solo una es correcta.
- **Abajo a la izquierda:** el **botiquín médico**.
- **Abajo a la derecha:** la flecha para **volver al mapa**.

### Aciertos y fallos

| Resultado   | Qué ocurre                                                                                                                                                |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Acierto** | Chispita lanza un rayo mágico desde su cuerno y quita **10 puntos de vida** al monstruo. Esa pregunta queda resuelta.                                     |
| **Fallo**   | El monstruo muestra la respuesta correcta y ataca con sombra, quitándole **10 puntos de vida** a Chispita. La pregunta puede volver a salir más adelante. |

El monstruo tiene 100 de vida y cada acierto quita 10, así que necesitas
**10 respuestas correctas** para ganar. Si fallas muchas veces y Chispita se
queda sin vida, pierdes el combate y tendrás que volver a intentarlo.

### El botiquín médico

![Botiquín abierto con una suma de tres cifras y teclado numérico](Ilustraciones/screenshots/03_01_botiquin.png)

Entre pregunta y pregunta puedes pulsar el botiquín de la esquina inferior
izquierda. Se abrirá con una **suma de tres cifras**, por ejemplo `312 + 444 =`.

1. Escribe el resultado con el **teclado numérico** de la tapa.
2. Pulsa **OK**.
3. Si la suma es correcta, Chispita recupera **30 puntos de vida**.
4. **Borrar** limpia la respuesta y cierra el botiquín sin gastarlo.

Solo puedes usar la curación **una vez por batalla**, así que conviene
guardarla para cuando de verdad te haga falta. Si te equivocas en la suma,
puedes volver a abrir el botiquín e intentarlo otra vez.

Al abrir el botiquín, la pregunta actual queda en pausa y vuelve a aparecer
cuando lo cierras.

### Ganar o perder

- **Victoria:** el monstruo cae, el pueblo se ilumina y queda marcado como
  **liberado** en el mapa. En el Pueblo 10 se reproduce una celebración
  especial.
- **Derrota:** si Chispita pierde toda su vida, el monstruo conserva el
  pueblo. Puedes volver al mapa y reintentar la batalla cuando quieras.

## 4. Opciones y control de tiempo

![Pantalla de opciones con el control de tiempo y el borrado de progreso](Ilustraciones/screenshots/02_01_opciones.png)

Pulsa la **rueda dentada** del mapa para abrir las opciones:

- **Control de tiempo:** actívalo con el interruptor y elige entre **15 y 30
  minutos** con el deslizador. Cuando se cumple el tiempo, el juego se pausa
  y muestra un aviso para descansar. El botón **Entendido** cierra el aviso y
  reinicia la cuenta.
- **Limpiar Progreso:** borra todos los pueblos liberados y vuelve a empezar
  desde el Pueblo 1. Pide confirmación antes de borrar.
- **Volver:** regresa al mapa sin cambiar nada.

El control de tiempo está desactivado por defecto y la duración inicial es de
20 minutos.

## Resumen de controles

| Acción                           | Cómo se hace                                           |
| -------------------------------- | ------------------------------------------------------ |
| Pasar la introducción            | Botón **Continuar**                                    |
| Entrar a un pueblo               | Pulsar el pueblo conquistado en el mapa                |
| Responder una multiplicación     | Pulsar una de las tres opciones de la nube             |
| Abrir el botiquín                | Pulsar el botiquín de abajo a la izquierda             |
| Escribir la suma                 | Teclado numérico de la tapa del botiquín               |
| Confirmar la suma                | Botón **OK**                                           |
| Borrar y cerrar el botiquín      | Botón **Borrar**                                       |
| Volver al mapa desde una batalla | Flecha de abajo a la derecha                           |
| Abrir opciones                   | Rueda dentada de arriba a la izquierda                 |
| Cerrar el juego                  | Botón de salir de abajo a la derecha del mapa y **Sí** |

## Trucos para las tablas

- Si una pregunta te cuesta, piensa en la tabla como una suma repetida:
  `4 × 3` es `4 + 4 + 4`.
- Para la tabla del 5, el resultado siempre termina en **0** o en **5**.
- Para la tabla del 10, basta con añadir un **0** al otro número.
- Si dudas entre dos opciones, descarta primero las que no tengan sentido por
  el tamaño: `7 × 8` no puede dar 15.
- Guarda el botiquín para los momentos con poca vida: con 30 puntos recuperas
  tres fallos.

¡Buena suerte liberando el Reino Unicornio, Chispita!

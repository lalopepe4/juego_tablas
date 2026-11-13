# Chispita y las Tablas Mágicas

Juego 2D para aprender las tablas de multiplicar, nacido de una idea de Lucía y
desarrollado junto a su papá. Chispita, un unicornio con crines y cola de colores
del arcoíris, debe liberar los diez pueblos del Reino Unicornio derrotando con
magia y matemáticas al Monstruo de la Sombra y a sus nueve secuaces.

## La historia

Chispita sale un día a buscar frambuesas y llega al **Reino Unicornio**, un
territorio pacífico de diez pueblos unidos por un camino. El **Monstruo de la
Sombra** y sus nueve secuaces lo han invadido: cada secuaz controla un pueblo y
lo cubre de oscuridad. Chispita decide usar su magia para liberar el reino, pueblo
por pueblo.

## Cómo se juega

1. **Mapa general.** Se muestran los diez pueblos unidos por el camino, cada uno
   con su monstruo. Al derrotar a un jefe, el pueblo se ilumina y se desbloquea
   el siguiente.
2. **Modo batalla.** Al llegar a un pueblo, Chispita y el monstruo empiezan con el
   100 % de vida, visible en la parte superior de la pantalla.
3. **Preguntas de multiplicación.** Una nube desciende al centro del ring con la
   pregunta de la tabla y tres opciones numéricas.
    - **Acierto:** Chispita lanza un rayo mágico desde su cuerno y resta vida al
      monstruo.
    - **Fallo:** el monstruo muestra la respuesta correcta y ataca con sombra,
      restándole vida al héroe.
4. **Botiquín médico.** Disponible en cualquier momento: para usarlo hay que
   resolver una suma de tres cifras e introducir el resultado en el teclado
   numérico de la tapa del botiquín, como una calculadora.
5. **Victoria y derrota.** Al responder correctamente las diez preguntas del
   secuaz, el monstruo cae y el pueblo queda libre. Si Chispita pierde toda su
   vida, el monstruo conserva el control del pueblo.

Además, la pantalla del mapa incluye un botón de opciones (rueda dentada) con
**control de tiempo** (alarma de uso entre 15 y 30 minutos) y **reset de
progreso**, y un botón de salir en la esquina inferior derecha que pide
confirmación antes de cerrar el juego.

## Ficha del proyecto

| Campo                  | Valor                                                                        |
| ---------------------- | ---------------------------------------------------------------------------- |
| Título                 | Chispita y las Tablas Mágicas                                                |
| Creadores              | Eduardo y Lucía (9 años)                                                     |
| Motor                  | Godot Engine (2D lateral tipo plataformas clásicas / RPG ligero)             |
| Público objetivo       | Niños en etapa escolar (práctica de tablas de multiplicar)                   |
| Clasificación estimada | PEGI 7 (fantasía caricaturesca, combates mágicos contra monstruos de sombra) |

## Estructura del repositorio

| Ruta             | Contenido                                                                 |
| ---------------- | ------------------------------------------------------------------------- |
| `juego/`         | Proyecto de Godot (`project.godot`), escenas, scripts y assets del juego. |
| `Docu/`          | Documentación de diseño, arte, sonido y planes técnicos.                  |
| `Ilustraciones/` | Ilustraciones originales, borradores, recortes y copias de revisión.      |
| `Sonido/`        | Efectos de sonido del juego.                                              |
| `packages/`      | Paquete `ilustrador` con el pipeline de generación de ilustraciones.      |
| `scripts/`       | Utilidades de apoyo del proyecto.                                         |
| `catalogo.toml`  | Catálogo de activos ilustrados y sus variantes.                           |

## Documentación

- [Cómo jugar](Howto_Play.md) — guía paso a paso con capturas de pantalla de la
  introducción, el mapa, la batalla y el botiquín.
- [Introducción](Docu/Introduccion.md) — idea original del juego y descripción del
  bucle de batalla.
- [GDD: Chispita y las Tablas Mágicas](Docu/GDD_Chispita.md) — documento de diseño
  completo: historia, progresión, mecánicas y opciones.
- [Plan de animaciones e ilustraciones de batalla](Docu/Plan_Animaciones.md) —
  estado del arte, poses, efectos y su integración en Godot.
- [Comparación de modelos de imagen en OpenRouter](Docu/Comparacion_Modelos.md) —
  apoyo para elegir el modelo de generación de ilustraciones.
- [Sonido](Docu/Sonido.md) — listado de efectos de sonido usados en el juego.
- [Info de sonidos](Docu/Info_Sonidos.md) — fuentes de audio y consideraciones de
  licencia.
- [Plan: MCP de ilustraciones](Docu/MCP_Plan.md) — arquitectura del paquete
  `ilustrador` y su servidor MCP.
- [Notas de Android](Android_Notes.md) — instalación del SDK en Linux,
  configuración de Godot para exportar el APK y envío al dispositivo de prueba.

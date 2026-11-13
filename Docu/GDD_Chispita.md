# GDD: Chispita y las Tablas Mágicas

## 1. Información General

• Título del Juego: Chispita y las Tablas Mágicas

• Creadores: Eduardo y Lucía (9 años)

• Motor: Godot Engine (2D lateral tipo plataformas clásicas / RPG ligero)

• Público Objetivo: Niños en etapa escolar (práctica de tablas de multiplicar)

• Clasificación Estimada: PEGI 7 (Fantasía caricaturesca, combates mágicos contra monstruos de sombra)

## 2. Historia y Premisa

Chispita es un tierno unicornio con crines y cola de colores del arcoíris que un día sale a buscar frambuesas. Durante su búsqueda, llega al Reino Unicornio, un territorio pacífico compuesto por diez pueblos conectados por un camino. Trágicamente, el Monstruo de la Sombra y sus nueve secuaces han invadido el reino, cubriendo todo de oscuridad y aterrorizando a los habitantes. Cada secuaz ha tomado el control de un pueblo. Chispita decide usar el poder de su magia y el conocimiento de las matemáticas para liberar el reino pueblo por pueblo.

## 3. Estructura y Progresión del Juego

• Mapa General: Muestra los diez pueblos unidos por un camino. Los nueve primeros están defendidos por los secuaces y repasan las tablas del 2 al 10. El Pueblo 10 está ocupado por el Monstruo de la Sombra y solo se desbloquea cuando Chispita ha liberado los nueve pueblos. Al derrotar a un secuaz, el pueblo se ilumina y queda liberado.

• Modo Aventura / Viaje: El héroe avanza por el camino hasta llegar al pueblo objetivo para iniciar la batalla.

## 4. Mecánicas del Modo Batalla

### Interfaz de Combate:

En la parte superior se muestran las barras de vida (HP al 100%) tanto de Chispita como del Monstruo de la Sombra.

### Mecánica Principal (Preguntas de Multiplicación):

Una nube desciende al centro del ring mostrando la pregunta de la tabla (10 preguntas por cada tabla/secuaz, de la del 2 a la del 10). Y se ofrecen tres opciones numéricas como posibles respuestas.

Si acierta: Chispita lanza un rayo mágico desde su cuerno, restando vida al monstruo.

Si falla: El monstruo acierta, genera sombra y ataca al héroe, restándole vida.

### Mecánica de Apoyo (Botiquín Médico):

Chispita puede usar un botiquín en cualquier momento de la batalla.

Para activarlo, debe resolver un reto de suma de tres cifras introduciendo el resultado en un teclado numérico integrado en la tapa del botiquín.

### El jefe final

El Monstruo de la Sombra no repasa una tabla fija: pregunta las diez multiplicaciones que más ha fallado Chispita. De cada tabla se toman las dos con más fallos (si no hay suficientes, se completan al azar) y, de esas dieciocho candidatas, se eligen las diez con más fallos. Así la última batalla es un repaso personalizado de lo que más cuesta.

### Victoria

Al responder correctamente las 10 preguntas del secuaz (o del jefe final), el monstruo es derrotado, el pueblo se libera y se regresa al mapa general.

### Derrota

Si Chispita falla al punto de quedar sin vida, el Monstruo gana la batalla y sigue manteniendo el control de su pueblo.

## Opciones

En la escena del mapa principal habrá un botón en la parte superior izquierda con forma de rueda dentada para abrir una pantalla de opciones:

### Control de tiempo

La configuración de tiempo permite al usuario tener una alarma de uso prolongado de la aplicación. Esto para fomentar el auto-control y el uso medido del tiempo de tablet/celular.

Propuesta de controles a usar:
Toggle Button para habilitar/deshabilitar el control de tiempo.

Si control de tiempo está habilitado:

- Un HSlider que permita configurar entre 15 y 30 minutos
- Un Label que muestre los minutos seleccionados con el HSlider

### Reset de progreso

En cualquier momento, el usuario podría querer limpiar su progreso para volver a empezar el juego.

Propuesta de controles a usar:
Button "Limpiar Progreso" que al presionarse, borra los pueblos liberados y el historial de fallos que usa el jefe final.

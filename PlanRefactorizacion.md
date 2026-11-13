# Plan de refactorización

Estado: **Fase 2 completada**.
Última actualización: 2026-11-13.

## Objetivo

Reducir la duplicación y el tamaño de `batalla.gd`, eliminar código muerto,
hacer más robusta la persistencia y dejar el proyecto preparado para pruebas
automáticas, sin cambiar el comportamiento visible del juego.

## Fase 1 — Quick wins

- [x] Crear `LienzoEscalado` y eliminar `_ajustar_lienzo` duplicado en las
      cuatro pantallas.
- [x] Mover el botón `Continuar` dentro del `Lienzo` de la introducción.
- [x] Eliminar código muerto del modelo (`Personaje.mensaje`,
      `Pregunta.intentos`, `Batalla.respuesta`, `_pantalla`).
- [x] Evitar el guardado en disco por cada tick del slider y comprobar los
      errores de `ConfigFile.save()`.
- [x] Inicializar el slider de minutos desde las constantes de `ControlTiempo`.
- [x] Excluir los scripts de desarrollo del export.
- [x] Ignorar artefactos de exportación y temporales en `.gitignore`.
- [x] Quitar Jolt Physics del proyecto 2D y el nodo `Titulo` oculto del mapa.
- [x] Deshabilitar `Volver` durante las animaciones y proteger los `await`.
- [x] Validar con Godot headless.

### Detalle de la Fase 1

- `juego/scripts/ui/lienzo_escalado.gd`: nuevo script asignado al nodo
  `Lienzo` de `mapa.tscn`, `introduccion.tscn`, `opciones.tscn` y
  `batalla.tscn`. El tamaño se configura con `@export var tamano`; la
  introducción usa `1024 × 1024` y el resto el valor por defecto `1280 × 720`.
- `introduccion.tscn`: `Continuar` ahora es hijo de `Lienzo`, por lo que se
  escala y se mueve con el cómic. `introduccion.gd` actualizó la ruta a
  `$Lienzo/Continuar`.
- `personaje.gd`: se eliminaron `mensaje` y `mensaje_changed`; la vida se
  recorta a `0` para que la barra no muestre valores negativos.
- `pregunta.gd`, `generador_opciones.gd` y `batalla_modelo.gd`: se eliminó
  `intentos`, `respuesta` y la conexión interna de `ganador_changed`.
  `Batalla.responder()` ahora también ignora respuestas si ya hay ganador.
  `Batalla.avanzar()` ya no reaplica el daño; la escena lo aplica una sola vez.
- `batalla.gd`: se eliminó `_pantalla` y las asignaciones redundantes de la
  escena. `Volver` empieza deshabilitado y solo se habilita cuando hay una
  pregunta esperando respuesta. Las esperas usan `_esperar()`, un tween ligado
  al nodo, y `_animar_ataque()` comprueba `is_running()` antes de esperar el
  efecto.
- `opciones.gd`: el slider actualiza la etiqueta en cada cambio, pero guarda
  con un `Timer` de 0,4 s; el toggle guarda de inmediato y al volver se fuerza
  el guardado. El mínimo, máximo y valor inicial salen de `ControlTiempo`.
- `control_tiempo.gd`: `configurar()` ya no escribe en disco; `guardar()`
  informa de errores con `push_error`.
- `progreso.gd`: `guardar()` informa de errores con `push_error`.
- `export_presets.cfg`: `exclude_filter="scripts/_*"` deja fuera del APK los
  scripts de captura y prueba.
- `.gitignore`: se añadieron `juego/*.apk`, `juego/*.apk.idsig`,
  `juego/*.pck` y `.tmp_revision/`.
- `project.godot`: se eliminó la sección `[physics]` con Jolt.
- `mapa.tscn`: se eliminó el nodo `Titulo`, que estaba oculto.

### Validación de la Fase 1

- `godot --headless --path juego --quit-after 5`: arranque sin errores.
- Instanciación de `introduccion.tscn`, `mapa.tscn`, `opciones.tscn` y
  `batalla.tscn` en headless: sin errores de script.
- `_prueba_barajar.gd`: la distribución de opciones sigue pasando.
- Comprobado que el slider arranca en `15/30/20`, que al cambiarlo a `25` se
  actualiza `ControlTiempo.minutos` y que el guardado diferido escribe
  `configuracion.cfg`.

### Pendiente inmediato de la Fase 1

- El APK y el `.idsig` siguen versionados aunque ya estén en `.gitignore`.
  Cuando se decida dejar de seguirlos:
  `git rm --cached juego/JuegoChispita.apk juego/JuegoChispita.apk.idsig`.
- Godot generó `juego/scripts/_prueba_barajar.gd.uid`; conviene commitearlo
  junto al script de prueba si se conserva.

## Fase 2 — Arquitectura

- [x] Extraer el botiquín a `scenes/ui/botiquin.tscn` + `scripts/batalla/botiquin.gd`.
- [x] Extraer las texturas/poses a `scripts/batalla/poses.gd`.
- [x] Extraer las animaciones a `scripts/batalla/animador.gd`.
- [x] Extraer los reproductores de audio a `scripts/batalla/sonidos.gd`.
- [x] Crear un tema compartido con variaciones (`BotonVerde`, `BotonRojo`,
      `BotonRedondo`, `PanelOscuro`, `TeclaBotiquin`, `OpcionRespuesta`).
- [x] Reducir la duplicación de `batalla.tscn` (teclado y opciones) y
      `mapa.tscn` (diez botones de pueblo).

### Detalle de la Fase 2

- `juego/scripts/batalla/poses.gd`: `Poses` guarda el mapa de texturas por
  personaje y estado, las texturas de los efectos y dos ayudas:
  `clave_enemigo(es_jefe)` y `textura(clave, estado)` con la pose base como
  respaldo.
- `juego/scripts/batalla/sonidos.gd`: `Sonidos` es un nodo que crea los tres
  reproductores (respuesta, ataque y final) y expone `respuesta(acierto)`,
  `ataque(es_heroe, es_jefe)`, `victoria(es_jefe)` y `derrota()`. En
  `batalla.tscn` cuelga como nodo `Sonidos`.
- `juego/scripts/batalla/animador.gd`: `AnimadorBatalla` concentra los tweens,
  las posiciones de reposo y `esperar()`. Las referencias a los nodos son
  `@export var` de tipo `NodePath` con valores por defecto relativos al nodo,
  así que en la escena solo hace falta añadir `Lienzo/Animador`.
- `juego/scripts/batalla/botiquin.gd` + `juego/scenes/ui/botiquin.tscn`:
  `Botiquin` es un `TextureRect` que gestiona su teclado, la suma y sus
  animaciones. Emite `solicitado`, `cancelado` y `resuelto(acierto)`; la
  batalla decide cuándo ofrecerlo, aplica la curación y restaura la pregunta
  suspendida. El nodo se instancia en `batalla.tscn`.
- `juego/scenes/ui/tema.tres`: tema compartido con las variaciones
  `BotonVerde`, `BotonRojo`, `BotonRedondo`, `PanelOscuro`, `TeclaBotiquin` y
  `OpcionRespuesta`. Se asigna a la raíz de `mapa.tscn`, `opciones.tscn` y
  `batalla.tscn`, al `Alarma` de `control_tiempo.tscn` y al botiquín.
- `juego/scenes/ui/marcador_pueblo.tscn`: botón compartido por los diez
  pueblos de `mapa.tscn`; cada instancia solo fija sus cuatro offsets y
  `mapa.gd` sigue rellenando texto, icono y tooltip.
- `batalla.tscn`: el botiquín es una instancia, las opciones y el teclado usan
  variaciones del tema y se eliminaron los `StyleBox` locales. `batalla.gd`
  pasa de ~695 a ~250 líneas y cachea `_es_jefe`.

### Validación de la Fase 2

- Instantánea headless de rectángulos, colores, bordes y tamaños de fuente de
  `mapa.tscn`, `opciones.tscn`, `control_tiempo.tscn` y `batalla.tscn` antes y
  después de la refactorización: sin diferencias.
- Prueba funcional headless de `batalla.tscn`: entrada de personajes, apertura
  y cancelación del botiquín, curación al acertar la suma, respuesta correcta
  y victoria con `batalla_terminada`.
- Prueba headless de la batalla del jefe: pose de sombras, sonido de ataque del
  jefe, derrota de Chispita y sonido final correcto.
- Navegación `main.tscn` → introducción → mapa → batalla sin errores.
- `godot --headless --path juego --quit-after 300`: arranque sin errores.
- `_prueba_barajar.gd`: la distribución de opciones sigue pasando.

### Pendiente inmediato de la Fase 2

- Siguen pendientes los dos puntos de la Fase 1 (dejar de versionar el APK y
  commitear `_prueba_barajar.gd.uid`).
- Los nuevos scripts de `scripts/batalla/` tienen su `.uid` generado por Godot;
  conviene commitearlos junto a los `.gd`.

## Fase 3 — Calidad

- [ ] Añadir pruebas headless de `GeneradorOpciones`, `Batalla`,
      `SelectorJefe` y `Progreso`.
- [ ] Añadir un script `scripts/test_juego.sh` y un flujo de CI.
- [ ] Validar los datos guardados al cargar (`pueblos_liberados`, `fallos`).
- [ ] Manejar el botón atrás de Android.
- [ ] Pedir confirmación antes de abandonar una batalla.

## Fase 4 — Producto

- [ ] Mostrar la tabla actual y el progreso (por ejemplo, `3/10`) en batalla.
- [ ] Permitir repasar pueblos ya liberados sin alterar el progreso.
- [ ] Añadir control de volumen o mute.
- [ ] Añadir soporte de teclado (`1/2/3`, `Enter`).
- [ ] Valorar un mapa generado desde datos en vez de diez nodos manuales.

## Registro de cambios

- 2026-11-13: creado el plan e iniciada la Fase 1.
- 2026-11-13: Fase 1 completada y validada en headless.
- 2026-11-13: Fase 2 completada: módulos de batalla, tema compartido y menos
  duplicación en las escenas; validada en headless.

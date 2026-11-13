# Plan de refactorización

Estado: **Fase 4 completada** (teclado y mapa por datos quedan fuera de alcance).
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

- [x] El APK y el `.idsig` ya no se versionan:
      `git rm --cached juego/JuegoChispita.apk juego/JuegoChispita.apk.idsig`.
      Siguen en disco e ignorados por `.gitignore`; queda pendiente el commit de la
      eliminación del índice.

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

- Los `.uid` de `scripts/batalla/` ya están versionados. La eliminación del APK
  del índice está hecha y pendiente de commit (ver Fase 1).

## Fase 3 — Calidad

- [x] Añadir pruebas headless de `GeneradorOpciones`, `Batalla`,
      `SelectorJefe` y `Progreso`.
- [x] Añadir un script `scripts/test_juego.sh` y un flujo de CI.
- [x] Validar los datos guardados al cargar (`pueblos_liberados`, `fallos`).
- [x] Manejar el botón atrás de Android.
- [x] Pedir confirmación antes de abandonar una batalla.

### Detalle de la Fase 3

- `juego/pruebas/`: runner `ejecutar.gd`, base `prueba_base.gd` y cinco
  suites (`prueba_generador_opciones.gd`, `prueba_batalla.gd`,
  `prueba_selector_jefe.gd`, `prueba_progreso.gd` y
  `prueba_navegacion.gd`). El runner imprime cada comprobación y sale con
  código 1 si hay algún fallo; las suites usan semillas fijas y escriben sus
  temporales en `OS.get_temp_dir()`.
- `GeneradorOpciones`: selección de preguntas pendientes, generación de tres
  opciones únicas y positivas, distribución de la respuesta correcta y
  `_barajar`.
- `Batalla` y `Personaje`: inicio, acierto y fallo, doble respuesta ignorada,
  daño pendiente, victoria/derrota por vida, victoria sin preguntas, avisos de
  `pregunta_changed`/`ganador_changed`, ataque, recorte de vida y curación.
- `SelectorJefe`: diez preguntas sin duplicados, tablas y multiplicadores
  válidos, reproducibilidad con la misma semilla, prioridad de las más
  falladas, relleno aleatorio y desempates.
- `Progreso`: tablas por pueblo, desbloqueo del jefe, idempotencia de
  `liberar_pueblo`, acumulación de fallos, ida y vuelta del guardado,
  reinicio, versión antigua, datos con tipos incorrectos o fuera de rango y
  archivo inexistente.
- `progreso.gd`: `ruta_guardado` configurable (las pruebas no tocan la partida
  real) y `_leer_pueblos()`/`_leer_fallos()` validan ids, duplicados, tipos y
  contadores no negativos antes de asignarlos.
- `control_tiempo.gd`: `ruta_guardado` configurable y
  `cerrar_alarma_si_visible()` para que el botón atrás cierre la alarma.
- `main.gd`: escucha `NOTIFICATION_WM_GO_BACK_REQUEST` y delega en
  `solicitar_atras()` de la pantalla actual; `project.godot` fija
  `config/quit_on_go_back=false` para no salir por defecto.
- Pantallas: la introducción cierra el juego, el mapa abre (o cierra) la
  confirmación de salida y también cierra el aviso del jefe, las opciones
  guardan y vuelven al mapa (o cierran su confirmación) y la batalla abre su
  nueva confirmación.
- `batalla.tscn`/`batalla.gd`: overlay `Confirmacion` con `PanelOscuro` y los
  botones `Sí, salir`/`Seguir`; `Volver` ya no sale directo, sino que pide
  confirmación, y el botón atrás la alterna. Si la batalla termina, el aviso
  se oculta.
- `scripts/test_juego.sh`: importa el proyecto (`--import`), ejecuta el runner
  headless y hace un arranque de humo (`--quit-after 120`). Usa `GODOT` del
  entorno o busca `godot`/`godot4` en el `PATH`.
- `.github/workflows/ci.yml`: descarga Godot 4.7.2 y ejecuta el script en cada
  push a `main` y en cada pull request.
- `export_presets.cfg`: `exclude_filter="scripts/_*,pruebas/*"` deja fuera del
  APK el código de pruebas.

### Validación de la Fase 3

- `./scripts/test_juego.sh`: 105 comprobaciones y 0 fallos, código de salida 0.
- Copia limpia del proyecto sin `.godot`: el `--import` reconstruye la caché de
  clases y las pruebas vuelven a pasar (mismo flujo que CI).
- Comprobado que `quit(1)` devuelve código 1, para que CI detecte los fallos.
- La suite de navegación simula `NOTIFICATION_WM_GO_BACK_REQUEST` sobre
  `main.gd` y verifica la confirmación del mapa.
- Diagnósticos del proyecto: sin errores ni avisos.

### Pendiente inmediato de la Fase 3

- La eliminación del APK del índice está hecha y pendiente de commit (ver Fase
  1).
- Los `.uid` de `juego/pruebas/` son nuevos; conviene commitearlos junto a las
  suites.
- El flujo de CI aún no se ha ejecutado en GitHub desde este entorno; conviene
  vigilar la primera ejecución y ajustar `GODOT_VERSION` si cambiara la
  versión del motor.

## Fase 4 — Producto

- [x] Mostrar la tabla actual y el progreso (por ejemplo, `3/10`) en batalla.
- [x] Permitir repasar pueblos ya liberados sin alterar el progreso.
- [x] Añadir un toggle de sonido (mute global).
- [x] Añadir el **Modo entrenamiento**: tabla del pueblo antes de la batalla.
- [ ] Soporte de teclado (`1/2/3`, `Enter`) — fuera de alcance por ahora.
- [ ] Mapa generado desde datos — descartado: las posiciones se ajustan a mano.

### Detalle de la Fase 4

- `juego/scripts/ajustes.gd` (autoload `Ajustes`): guarda `sonido_activo` y
  `modo_entrenamiento` en `user://ajustes.cfg`, aplica el mute desde el bus
  Master, valida los booleanos al cargar y permite cambiar la ruta en pruebas.
- `opciones.tscn`/`opciones.gd`: nueva variación de tema `OpcionAjuste` para los
  `CheckButton` y dos toggles, **Sonido** y **Modo entrenamiento**, con una
  ayuda bajo el segundo. Guardan al instante y el panel crece a 760 × 677 para
  que quepa todo.
- `assets/ui/interruptor_apagado.svg` e `interruptor_encendido.svg`: iconos de
  64 × 32 para `OpcionAjuste`, en lugar de los 32 × 16 por defecto, para que el
  interruptor quede a la altura de la fuente de 32 px y de los botones.
- `batalla_modelo.gd`: `total_preguntas()` y `preguntas_respondidas()` para
  calcular el progreso desde las preguntas marcadas.
- `batalla.gd`/`batalla.tscn`: nueva etiqueta `Lienzo/Progreso` con
  `Tabla del X · n/10` (o `Jefe final · n/10`) y prefijo `Repaso · ` cuando
  corresponde. La señal `batalla_terminada` incluye `repaso`; en un repaso no
  se registran fallos, el mensaje de victoria es “¡Repaso completado!” y el
  contador se actualiza también al ganar.
- `mapa.gd`/`mapa.tscn`: los pueblos liberados vuelven a ser pulsables y
  emiten `batalla_solicitada(pueblo_id, repaso)`. Su marcador cambia al icono
  del monstruo derrotado (`monstruo_secuaz_derrotado.png` o
  `monstruo_de_sombras_derrotado.png`) para distinguirlos de los conquistados.
  Con el modo entrenamiento activo, pulsar un secuaz abre el popup `Tabla` con
  las diez multiplicaciones del pueblo, `Aceptar` (empieza la batalla) y
  `Volver`; el jefe se salta la tabla porque su batalla mezcla tablas. El botón
  atrás cierra el popup.
- `main.gd`: arranca la batalla con el flag `repaso` y solo llama a
  `Progreso.liberar_pueblo()` si hay victoria y no es un repaso.
- `Readme.md`: describe el repaso, el modo entrenamiento y el toggle de sonido.

### Validación de la Fase 4

- `./scripts/test_juego.sh`: 142 comprobaciones y 0 fallos.
- `prueba_batalla.gd` cubre el progreso; `prueba_ajustes.gd` cubre valores por
  defecto, guardado, mute del bus Master y datos inválidos; `prueba_navegacion.gd`
  cubre repaso, iconos de pueblo liberado/conquistado, popup de entrenamiento y
  los dos toggles de opciones.
- Comprobado en headless que el panel de opciones (760 × 677) cabe en el lienzo
  de 720, que el popup de tabla mide 760 × 500 con diez filas y que la etiqueta
  de progreso (y = 8…46) no se solapa con la nube (y = 49). Los `CheckButton`
  usan iconos de 64 × 32 (antes 32 × 16).
- Diagnósticos del proyecto: sin errores ni avisos.

### Pendiente inmediato de la Fase 4

- Regenerar `Ilustraciones/screenshots/02_01_opciones.png` (ahora incluye los
  toggles de sonido y entrenamiento) y añadir una captura de la tabla de
  entrenamiento; conviene hacerlo con ventana, no en headless.
- El soporte de teclado y el mapa por datos quedan fuera de esta fase por
  decisión de producto.

## Registro de cambios

- 2026-11-13: creado el plan e iniciada la Fase 1.
- 2026-11-13: Fase 1 completada y validada en headless.
- 2026-11-13: Fase 2 completada: módulos de batalla, tema compartido y menos
  duplicación en las escenas; validada en headless.
- 2026-11-13: Fase 3 completada: pruebas headless, script de CI, validación del
  guardado, botón atrás de Android y confirmación al abandonar la batalla.
- 2026-11-13: se dejaron de versionar `JuegoChispita.apk` y su `.idsig`
  (`git rm --cached`); siguen en disco e ignorados.
- 2026-11-13: Fase 4 completada: progreso en batalla, repaso de pueblos,
  toggle de sonido y modo entrenamiento con la tabla del pueblo.
- 2026-11-13: interruptores de la pantalla de opciones con iconos propios de
  64 × 32.
- 2026-11-13: los pueblos liberados muestran al monstruo derrotado en el mapa
  para distinguirlos de los conquistados.

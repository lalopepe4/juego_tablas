extends PruebaBase

## Pruebas de navegacion, boton atras, repaso y modo entrenamiento.

var _main: Node
var _progreso: Node
var _tiempo: Node
var _ajustes: Node
var _ruta_tiempo := ""
var _ruta_ajustes := ""
var _pueblos_originales: Array = []
var _fallos_originales: Dictionary = {}
var _sonido_original := true
var _entrenamiento_original := false


func _init() -> void:
	nombre = "Navegacion y boton atras"


func ejecutar() -> void:
	var arbol := Engine.get_main_loop() as SceneTree
	_progreso = arbol.root.get_node("Progreso")
	_tiempo = arbol.root.get_node("ControlTiempo")
	_ajustes = arbol.root.get_node("Ajustes")
	_preparar_estado()

	_main = load("res://scenes/main.tscn").instantiate()
	arbol.root.add_child(_main)
	await arbol.process_frame

	igual("arranca en la introduccion", "Introduccion", _nombre_pantalla())
	_main.mostrar_mapa()
	igual("muestra el mapa", "Mapa", _nombre_pantalla())

	_main.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	comprobar("atras en el mapa abre la confirmacion", _nodo("Confirmacion").visible)
	_main._al_pulsar_atras()
	comprobar("atras cierra la confirmacion", not _nodo("Confirmacion").visible)

	_main.mostrar_opciones()
	igual("muestra las opciones", "Opciones", _nombre_pantalla())
	_main._al_pulsar_atras()
	igual("atras en opciones vuelve al mapa", "Mapa", _nombre_pantalla())

	await _probar_batalla_y_confirmacion(arbol)
	_probar_repaso()
	await _probar_entrenamiento(arbol)
	_probar_toggles()

	_main.queue_free()
	await arbol.process_frame
	await arbol.process_frame
	_restaurar_estado()


func _preparar_estado() -> void:
	_ruta_tiempo = OS.get_temp_dir().path_join("juego_chispita_tiempo_nav.cfg")
	_ruta_ajustes = OS.get_temp_dir().path_join("juego_chispita_ajustes_nav.cfg")
	_tiempo.ruta_guardado = _ruta_tiempo
	_ajustes.ruta_guardado = _ruta_ajustes
	_pueblos_originales = _progreso.pueblos_liberados.duplicate()
	_fallos_originales = _progreso.fallos.duplicate(true)
	_sonido_original = _ajustes.sonido_activo
	_entrenamiento_original = _ajustes.modo_entrenamiento
	_progreso.pueblos_liberados.clear()
	_progreso.fallos.clear()


func _restaurar_estado() -> void:
	_tiempo.ruta_guardado = _tiempo.RUTA_GUARDADO
	_ajustes.ruta_guardado = _ajustes.RUTA_GUARDADO
	_progreso.pueblos_liberados.assign(_pueblos_originales)
	_progreso.fallos = _fallos_originales.duplicate(true)
	_ajustes.modo_entrenamiento = _entrenamiento_original
	_ajustes.sonido_activo = _sonido_original
	_ajustes._aplicar_sonido()
	if FileAccess.file_exists(_ruta_tiempo):
		DirAccess.remove_absolute(_ruta_tiempo)
	if FileAccess.file_exists(_ruta_ajustes):
		DirAccess.remove_absolute(_ruta_ajustes)


func _probar_batalla_y_confirmacion(arbol: SceneTree) -> void:
	var mapa := _pantalla()
	mapa.batalla_solicitada.emit(0, false)
	igual("inicia la batalla", "Batalla", _nombre_pantalla())
	await arbol.process_frame

	_main._al_pulsar_atras()
	comprobar("atras en batalla abre la confirmacion", _nodo("Confirmacion").visible)
	_main._al_pulsar_atras()
	comprobar("atras cierra la confirmacion de batalla", not _nodo("Confirmacion").visible)

	_nodo("Volver").pressed.emit()
	comprobar("el boton Volver pide confirmacion", _nodo("Confirmacion").visible)
	_nodo("Confirmacion/Panel/Margen/Contenido/Botones/No").pressed.emit()
	comprobar("Seguir cierra la confirmacion", not _nodo("Confirmacion").visible)

	_nodo("Volver").pressed.emit()
	_nodo("Confirmacion/Panel/Margen/Contenido/Botones/Si").pressed.emit()
	igual("salir de la batalla vuelve al mapa", "Mapa", _nombre_pantalla())


func _probar_repaso() -> void:
	_ajustes.modo_entrenamiento = false
	_progreso.pueblos_liberados.assign([0])
	_main.mostrar_mapa()
	var boton: Button = _pantalla().get_node("Lienzo/Pueblos/Pueblo1")
	comprobar("el pueblo liberado se puede pulsar", not boton.disabled)
	igual(
		"el pueblo liberado muestra al monstruo derrotado",
		load("res://assets/personajes/monstruo_secuaz_derrotado.png"),
		boton.icon
	)
	var conquistado: Button = _pantalla().get_node("Lienzo/Pueblos/Pueblo2")
	igual(
		"el pueblo conquistado muestra al monstruo",
		load("res://assets/personajes/monstruo_secuaz_frente.png"),
		conquistado.icon
	)
	boton.pressed.emit()
	igual("el repaso abre la batalla", "Batalla", _nombre_pantalla())
	comprobar("la batalla es de repaso", _pantalla().repaso)
	_main._al_terminar_batalla(true, 0, true)
	igual("el repaso vuelve al mapa", "Mapa", _nombre_pantalla())
	comprobar("el pueblo sigue liberado", _progreso.esta_liberado(0))
	igual("el pueblo no se duplica", 1, _progreso.pueblos_liberados.size())
	var tras_repaso: Button = _pantalla().get_node("Lienzo/Pueblos/Pueblo1")
	igual(
		"el repaso conserva el icono de derrotado",
		load("res://assets/personajes/monstruo_secuaz_derrotado.png"),
		tras_repaso.icon
	)

	_progreso.pueblos_liberados.assign([0, 9])
	_main.mostrar_mapa()
	var jefe: Button = _pantalla().get_node("Lienzo/Pueblos/Pueblo10")
	igual(
		"el jefe liberado muestra al monstruo derrotado",
		load("res://assets/personajes/monstruo_de_sombras_derrotado.png"),
		jefe.icon
	)


func _probar_entrenamiento(arbol: SceneTree) -> void:
	_ajustes.modo_entrenamiento = true
	_main.mostrar_mapa()
	var boton: Button = _pantalla().get_node("Lienzo/Pueblos/Pueblo2")
	boton.pressed.emit()
	comprobar("el entrenamiento abre la tabla", _nodo("Tabla").visible)
	igual(
		"el titulo es la tabla del pueblo",
		"Tabla del 3",
		_nodo("Tabla/Panel/Margen/Contenido/Titulo").text
	)
	igual(
		"la tabla tiene diez filas",
		10,
		_nodo("Tabla/Panel/Margen/Contenido/Filas").get_child_count()
	)
	igual(
		"la primera fila es correcta",
		"3 × 1 = 3",
		_nodo("Tabla/Panel/Margen/Contenido/Filas").get_child(0).text
	)
	_nodo("Tabla/Panel/Margen/Contenido/Botones/Aceptar").pressed.emit()
	igual("Aceptar inicia la batalla", "Batalla", _nombre_pantalla())
	igual("la batalla no es de repaso", false, _pantalla().repaso)
	igual("la batalla es del pueblo 2", 1, _pantalla().pueblo_id)
	await arbol.process_frame
	_main.mostrar_mapa()


func _probar_toggles() -> void:
	_main.mostrar_opciones()
	var sonido: CheckButton = _nodo("Lienzo/Panel/Margen/Contenido/Sonido")
	var entrenamiento: CheckButton = _nodo(
		"Lienzo/Panel/Margen/Contenido/Entrenamiento"
	)
	var sonido_inicial: bool = _ajustes.sonido_activo
	igual("el toggle de sonido refleja el ajuste", sonido_inicial, sonido.button_pressed)
	igual("el toggle de entrenamiento refleja el ajuste", true, entrenamiento.button_pressed)

	sonido.button_pressed = not sonido_inicial
	igual(
		"cambiar el sonido actualiza el ajuste",
		not sonido_inicial,
		_ajustes.sonido_activo
	)
	entrenamiento.button_pressed = false
	igual(
		"cambiar el entrenamiento actualiza el ajuste",
		false,
		_ajustes.modo_entrenamiento
	)
	_main.mostrar_mapa()


func _pantalla() -> Node:
	return _main._pantalla


func _nombre_pantalla() -> String:
	return String(_pantalla().name)


func _nodo(ruta: String) -> Node:
	return _pantalla().get_node(ruta)

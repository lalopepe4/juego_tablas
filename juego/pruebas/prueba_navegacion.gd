extends PruebaBase

## Pruebas de navegacion entre pantallas y del boton atras de Android.

var _main: Node
var _ruta_tiempo := ""


func _init() -> void:
	nombre = "Navegacion y boton atras"


func ejecutar() -> void:
	var arbol := Engine.get_main_loop() as SceneTree
	var tiempo := arbol.root.get_node("ControlTiempo")
	_ruta_tiempo = OS.get_temp_dir().path_join("juego_chispita_tiempo_prueba.cfg")
	tiempo.ruta_guardado = _ruta_tiempo

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

	var mapa := _pantalla()
	mapa.batalla_solicitada.emit(0)
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

	_main.queue_free()
	await arbol.process_frame
	await arbol.process_frame
	tiempo.ruta_guardado = tiempo.RUTA_GUARDADO
	if FileAccess.file_exists(_ruta_tiempo):
		DirAccess.remove_absolute(_ruta_tiempo)


func _pantalla() -> Node:
	return _main._pantalla


func _nombre_pantalla() -> String:
	return String(_pantalla().name)


func _nodo(ruta: String) -> Node:
	return _pantalla().get_node(ruta)

extends SceneTree

## Genera las capturas de pantalla de la documentacion.
##
## Uso:
##   godot --path juego --resolution 1280x720 --script res://scripts/_captura_escenas.gd
##
## No toca el progreso guardado del jugador: solo cambia el estado en memoria.

const CARPETA := "../Ilustraciones/screenshots"

var _destino: String
var _progreso: Node
var _tiempo: Node


func _initialize() -> void:
	_destino = ProjectSettings.globalize_path("res://").path_join(CARPETA).simplify_path()
	DirAccess.make_dir_recursive_absolute(_destino)
	_progreso = root.get_node("Progreso")
	_tiempo = root.get_node("ControlTiempo")
	_capturar.call_deferred()


func _capturar() -> void:
	# Sin alarma de tiempo y con el mapa recien empezado.
	_tiempo.activo = false
	_progreso.pueblos_liberados.clear()
	_progreso.fallos.clear()

	var mapa := await _mostrar("res://scenes/mapa.tscn")
	await _guardar("02_mapa.png")

	mapa.get_node("Lienzo/Pueblos/Pueblo10").pressed.emit()
	await _guardar("02_02_jefe_bloqueado.png")
	mapa.get_node("AvisoJefe/Panel/Margen/Contenido/Aceptar").pressed.emit()

	mapa.get_node("Salir").pressed.emit()
	await _guardar("02_03_salir.png")
	mapa.get_node("Confirmacion/Panel/Margen/Contenido/Botones/No").pressed.emit()
	await _cerrar(mapa)

	# Mapa con los nueve secuaces vencidos: el jefe ya se puede pulsar.
	_progreso.pueblos_liberados.assign([0, 1, 2, 3, 4, 5, 6, 7, 8])
	mapa = await _mostrar("res://scenes/mapa.tscn")
	await _guardar("02_04_jefe_desbloqueado.png")
	await _cerrar(mapa)

	var opciones := await _mostrar("res://scenes/opciones.tscn")
	await _guardar("02_01_opciones.png")
	await _cerrar(opciones)

	print("CAPTURAS EN ", _destino)
	quit()


func _mostrar(ruta: String) -> Node:
	var escena: Node = load(ruta).instantiate()
	root.add_child(escena)
	for i in 6:
		await process_frame
	return escena


func _cerrar(escena: Node) -> void:
	escena.queue_free()
	await process_frame
	await process_frame


func _guardar(nombre: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var imagen := root.get_texture().get_image()
	var ruta := _destino.path_join(nombre)
	var error := imagen.save_png(ruta)
	print(nombre, " ", imagen.get_size(), " error=", error)

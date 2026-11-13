extends Control

## Punto de entrada: introduccion, mapa del reino y modo batalla.

const ESCENA_INTRODUCCION := preload("res://scenes/introduccion.tscn")
const ESCENA_MAPA := preload("res://scenes/mapa.tscn")
const ESCENA_OPCIONES := preload("res://scenes/opciones.tscn")
const ESCENA_BATALLA := preload("res://scenes/batalla.tscn")

@onready var _contenedor: Control = $Contenedor

## Pantalla visible; cada una decide que hacer con el boton atras.
var _pantalla: Node


func _ready() -> void:
	mostrar_introduccion()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_al_pulsar_atras()


func mostrar_introduccion() -> void:
	var introduccion := ESCENA_INTRODUCCION.instantiate()
	introduccion.continuar_solicitada.connect(mostrar_mapa)
	_cambiar(introduccion)


func mostrar_mapa() -> void:
	var mapa := ESCENA_MAPA.instantiate()
	mapa.batalla_solicitada.connect(_iniciar_batalla)
	mapa.opciones_solicitada.connect(mostrar_opciones)
	_cambiar(mapa)


func mostrar_opciones() -> void:
	var opciones := ESCENA_OPCIONES.instantiate()
	opciones.volver_solicitada.connect(mostrar_mapa)
	_cambiar(opciones)


func _iniciar_batalla(pueblo_id: int, repaso := false) -> void:
	var batalla := ESCENA_BATALLA.instantiate()
	batalla.pueblo_id = pueblo_id
	batalla.repaso = repaso
	batalla.batalla_terminada.connect(_al_terminar_batalla)
	batalla.volver_solicitada.connect(mostrar_mapa)
	_cambiar(batalla)


func _al_terminar_batalla(victoria: bool, pueblo_id: int, repaso: bool) -> void:
	if victoria and not repaso:
		Progreso.liberar_pueblo(pueblo_id)
	mostrar_mapa()


## Boton atras de Android: primero cierra la alarma de tiempo y despues deja
## que la pantalla actual decida (volver, confirmar salida o cerrar el juego).
func _al_pulsar_atras() -> void:
	if ControlTiempo.cerrar_alarma_si_visible():
		return
	if _pantalla != null and _pantalla.has_method("solicitar_atras"):
		_pantalla.solicitar_atras()


func _cambiar(nodo: Node) -> void:
	for hijo in _contenedor.get_children():
		_contenedor.remove_child(hijo)
		hijo.queue_free()
	_contenedor.add_child(nodo)
	_pantalla = nodo

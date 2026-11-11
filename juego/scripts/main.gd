extends Control

## Punto de entrada: alterna entre el mapa del reino y el modo batalla.

const ESCENA_MAPA := preload("res://scenes/mapa.tscn")
const ESCENA_BATALLA := preload("res://scenes/batalla.tscn")

@onready var _contenedor: Control = $Contenedor


func _ready() -> void:
	mostrar_mapa()


func mostrar_mapa() -> void:
	var mapa := ESCENA_MAPA.instantiate()
	mapa.batalla_solicitada.connect(_iniciar_batalla)
	_cambiar(mapa)


func _iniciar_batalla(pueblo_id: int) -> void:
	var batalla := ESCENA_BATALLA.instantiate()
	batalla.pueblo_id = pueblo_id
	batalla.batalla_terminada.connect(_al_terminar_batalla)
	_cambiar(batalla)


func _al_terminar_batalla(victoria: bool, pueblo_id: int) -> void:
	if victoria:
		Progreso.liberar_pueblo(pueblo_id)
	mostrar_mapa()


func _cambiar(nodo: Node) -> void:
	for hijo in _contenedor.get_children():
		_contenedor.remove_child(hijo)
		hijo.queue_free()
	_contenedor.add_child(nodo)

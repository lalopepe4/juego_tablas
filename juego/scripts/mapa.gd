extends Control

## Mapa del Reino Unicornio: diez pueblos unidos por el camino.
## Los pueblos liberados quedan deshabilitados; el resto inicia una batalla.

signal batalla_solicitada(pueblo_id: int)

@onready var _pueblos: HBoxContainer = $Pueblos


func _ready() -> void:
	_crear_botones()


func _crear_botones() -> void:
	for pueblo_id in Progreso.TOTAL_PUEBLOS:
		var boton := Button.new()
		boton.custom_minimum_size = Vector2(100, 80)
		boton.pressed.connect(_al_pulsar_pueblo.bind(pueblo_id))
		_pueblos.add_child(boton)
	_actualizar_botones()


func _actualizar_botones() -> void:
	for pueblo_id in _pueblos.get_child_count():
		var boton := _pueblos.get_child(pueblo_id) as Button
		var liberado := Progreso.esta_liberado(pueblo_id)
		boton.disabled = liberado
		boton.text = "Pueblo %d\n%s" % [pueblo_id + 1, "liberado" if liberado else "secuaz"]


func _al_pulsar_pueblo(pueblo_id: int) -> void:
	batalla_solicitada.emit(pueblo_id)

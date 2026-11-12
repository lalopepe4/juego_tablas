extends Control

## Mapa del Reino Unicornio: diez pueblos unidos por el camino.
## Los pueblos liberados quedan deshabilitados; el resto inicia una batalla.

signal batalla_solicitada(pueblo_id: int)

const ICONO_SECUAZ := preload("res://assets/personajes/monstruo_secuaz.png")
const ICONO_SOMBRAS := preload("res://assets/personajes/monstruo_de_sombras.png")

@onready var _pueblos: HBoxContainer = $Pueblos


func _ready() -> void:
	_crear_botones()


func _crear_botones() -> void:
	for pueblo_id in Progreso.TOTAL_PUEBLOS:
		var boton := Button.new()
		boton.custom_minimum_size = Vector2(110, 150)
		boton.pressed.connect(_al_pulsar_pueblo.bind(pueblo_id))
		_pueblos.add_child(boton)

		var icono := TextureRect.new()
		icono.name = "Icono"
		icono.texture = (
			ICONO_SOMBRAS if pueblo_id == Progreso.TOTAL_PUEBLOS - 1 else ICONO_SECUAZ
		)
		icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icono.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icono.offset_bottom = -44.0
		boton.add_child(icono)

		var etiqueta := Label.new()
		etiqueta.name = "Etiqueta"
		etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
		etiqueta.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		etiqueta.offset_top = -44.0
		boton.add_child(etiqueta)
	_actualizar_botones()


func _actualizar_botones() -> void:
	for pueblo_id in _pueblos.get_child_count():
		var boton := _pueblos.get_child(pueblo_id) as Button
		var liberado := Progreso.esta_liberado(pueblo_id)
		boton.disabled = liberado
		var etiqueta := boton.get_node("Etiqueta") as Label
		etiqueta.text = "Pueblo %d\n%s" % [pueblo_id + 1, "liberado" if liberado else "secuaz"]
		etiqueta.modulate = Color(0.6, 0.6, 0.6, 1) if liberado else Color.WHITE
		var icono := boton.get_node("Icono") as TextureRect
		icono.modulate = Color(0.45, 0.45, 0.45, 0.7) if liberado else Color.WHITE


func _al_pulsar_pueblo(pueblo_id: int) -> void:
	batalla_solicitada.emit(pueblo_id)

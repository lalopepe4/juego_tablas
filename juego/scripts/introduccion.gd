extends Control

## Pantalla de introduccion: muestra el comic del encuentro entre Chispita y
## el Monstruo de Sombras y espera a que se pulse Continuar.

signal continuar_solicitada

## Tamano de diseno del comic. El lienzo se escala en bloque para que la
## imagen y el boton conserven su posicion en cualquier pantalla.
const TAMANO_LIENZO := Vector2(1024.0, 1024.0)

@onready var _lienzo: Control = $Lienzo
@onready var _continuar: Button = $Continuar


func _ready() -> void:
	_ajustar_lienzo()
	get_viewport().size_changed.connect(_ajustar_lienzo)
	_continuar.pressed.connect(_al_pulsar_continuar)


## Escala el lienzo para que quepa entero en la pantalla y lo centra.
func _ajustar_lienzo() -> void:
	var vista := get_viewport_rect().size
	var escala := minf(vista.x / TAMANO_LIENZO.x, vista.y / TAMANO_LIENZO.y)
	_lienzo.scale = Vector2(escala, escala)
	_lienzo.position = (vista - TAMANO_LIENZO * escala) * 0.5


func _al_pulsar_continuar() -> void:
	continuar_solicitada.emit()

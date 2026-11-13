extends Control

## Pantalla de introduccion: muestra el comic del encuentro entre Chispita y
## el Monstruo de Sombras y espera a que se pulse Continuar.

signal continuar_solicitada

@onready var _continuar: Button = $Lienzo/Continuar


func _ready() -> void:
	_continuar.pressed.connect(_al_pulsar_continuar)


func _al_pulsar_continuar() -> void:
	continuar_solicitada.emit()

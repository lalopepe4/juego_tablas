extends Control

## Barra de vida reutilizable para Chispita y para los secuaces.

@onready var _barra: ProgressBar = $Barra
@onready var _etiqueta: Label = $Etiqueta


func set_vida(actual: int, maxima: int) -> void:
	_barra.max_value = maxima
	_barra.value = actual
	_etiqueta.text = "%d / %d" % [actual, maxima]

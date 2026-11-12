extends Control

## Barra de vida reutilizable para Chispita y para los secuaces.

const DURACION_CAMBIO := 0.4

@onready var _barra: ProgressBar = $Barra
@onready var _etiqueta: Label = $Etiqueta

var _tween: Tween


func set_vida(actual: int, maxima: int) -> void:
	_barra.max_value = maxima
	_etiqueta.text = "%d / %d" % [actual, maxima]

	if _tween != null and _tween.is_valid():
		_tween.kill()
	if not is_inside_tree():
		_barra.value = actual
		return

	_tween = create_tween()
	_tween.tween_property(_barra, "value", float(actual), DURACION_CAMBIO).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_OUT)

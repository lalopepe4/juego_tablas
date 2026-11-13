class_name Pregunta
extends RefCounted

## Una pregunta de la tabla de multiplicar de un pueblo.

var multiplicando: int
var multiplicador: int
var opciones: Array[String] = []
var intentos := 0
var respondida := false


func _init(p_multiplicando: int, p_multiplicador: int) -> void:
	multiplicando = p_multiplicando
	multiplicador = p_multiplicador


var respuesta: int:
	get:
		return multiplicando * multiplicador


var respuesta_literal: String:
	get:
		return str(respuesta)


## Identifica la multiplicacion para guardar sus fallos en el progreso.
var clave: String:
	get:
		return "%d x %d" % [multiplicando, multiplicador]


var pregunta_literal: String:
	get:
		return "%d × %d" % [multiplicando, multiplicador]

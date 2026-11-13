class_name Pueblo
extends RefCounted

## Un pueblo del reino, con las preguntas que hay que responder para liberarlo.

var nombre: String
var preguntas: Array[Pregunta] = []


func _init(p_nombre: String, p_preguntas: Array[Pregunta]) -> void:
	nombre = p_nombre
	preguntas = p_preguntas


## Pueblo de un secuaz: repasa la tabla completa del multiplicando indicado.
static func de_tabla(multiplicando: int) -> Pueblo:
	var preguntas: Array[Pregunta] = []
	for multiplicador in range(1, 11):
		preguntas.append(Pregunta.new(multiplicando, multiplicador))
	return Pueblo.new("Pueblo del %d" % multiplicando, preguntas)


## Pueblo del jefe final: las preguntas se eligen entre las tablas ya jugadas.
static func jefe(preguntas_jefe: Array[Pregunta]) -> Pueblo:
	return Pueblo.new("Monstruo de Sombras", preguntas_jefe)

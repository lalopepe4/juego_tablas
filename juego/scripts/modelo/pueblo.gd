class_name Pueblo
extends RefCounted

## Un pueblo del reino, con su tabla de multiplicar.

var nombre: String
var preguntas: Array[Pregunta] = []


func _init(multiplicando: int) -> void:
	nombre = "Pueblo del %d" % multiplicando
	for i in range(1, 11):
		preguntas.append(Pregunta.new(multiplicando, i))

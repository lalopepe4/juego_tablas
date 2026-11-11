class_name GeneradorPreguntas
extends RefCounted

## Genera las preguntas del modo batalla.
##
## Segun Docu/Introduccion.md: cada batalla son diez preguntas de la tabla del
## pueblo, con tres opciones de respuesta. El botiquin pide una suma de tres
## cifras que el jugador teclea como en una calculadora.

const PREGUNTAS_POR_BATALLA := 10
const OPCIONES_POR_PREGUNTA := 3


static func pregunta_tabla(tabla: int, rng: RandomNumberGenerator) -> Dictionary:
	var factor := rng.randi_range(1, 10)
	var correcta := tabla * factor
	return {
		"texto": "%d × %d" % [tabla, factor],
		"correcta": correcta,
		"opciones": _opciones(correcta, rng),
	}


static func pregunta_botiquin(rng: RandomNumberGenerator) -> Dictionary:
	var a := rng.randi_range(100, 499)
	var b := rng.randi_range(100, 499)
	return {
		"texto": "%d + %d" % [a, b],
		"correcta": a + b,
	}


## Tres opciones distintas y positivas: la correcta mas dos errores tipicos
## (fallar por uno o por una decena).
static func _opciones(correcta: int, rng: RandomNumberGenerator) -> Array[int]:
	var opciones: Array[int] = [correcta]
	var deltas: Array[int] = [1, -1, 2, -2, 10, -10]
	var intentos := 0
	while opciones.size() < OPCIONES_POR_PREGUNTA and intentos < 50:
		intentos += 1
		var candidato := correcta + deltas[rng.randi_range(0, deltas.size() - 1)]
		if candidato > 0 and not opciones.has(candidato):
			opciones.append(candidato)
	_barajar(opciones, rng)
	return opciones


static func _barajar(valores: Array[int], rng: RandomNumberGenerator) -> void:
	for i in range(valores.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var temporal := valores[i]
		valores[i] = valores[j]
		valores[j] = temporal

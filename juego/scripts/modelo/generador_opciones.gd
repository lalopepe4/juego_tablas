class_name GeneradorOpciones
extends RefCounted

## Elige la siguiente pregunta y genera sus opciones de respuesta.

const DELTAS := [1, -1, 2, -2, 5, -5, 10, -10]
const NUMERO_DE_OPCIONES := 3


static func seleccionar_pregunta(
	pueblo: Pueblo, rng: RandomNumberGenerator
) -> Pregunta:
	var no_respondidas: Array[Pregunta] = []
	for pregunta in pueblo.preguntas:
		if not pregunta.respondida:
			no_respondidas.append(pregunta)
	if no_respondidas.is_empty():
		return null

	var pregunta: Pregunta = no_respondidas[
		rng.randi_range(0, no_respondidas.size() - 1)
	]
	pregunta.opciones = _generar_opciones(pregunta, rng, NUMERO_DE_OPCIONES)
	return pregunta


static func _generar_opciones(
	pregunta: Pregunta, rng: RandomNumberGenerator, numero: int
) -> Array[String]:
	var valores: Array[int] = [pregunta.respuesta]
	var intentos := 0
	while valores.size() < numero and intentos < 100:
		intentos += 1
		var delta: int = DELTAS[rng.randi_range(0, DELTAS.size() - 1)]
		var opcion := pregunta.respuesta + delta
		if opcion <= 0 or valores.has(opcion):
			continue
		valores.append(opcion)

	_barajar(valores, rng)
	var opciones: Array[String] = []
	for valor in valores:
		opciones.append(str(valor))
	return opciones


static func _barajar(valores: Array[int], rng: RandomNumberGenerator) -> void:
	for i in range(valores.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var temporal := valores[i]
		valores[i] = valores[j]
		valores[j] = temporal

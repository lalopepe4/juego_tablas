extends PruebaBase

## Pruebas de GeneradorOpciones: seleccion de preguntas y generacion de opciones.

func _init() -> void:
	nombre = "GeneradorOpciones"


func ejecutar() -> void:
	_probar_seleccion()
	_probar_opciones()
	_probar_barajar()


func _probar_seleccion() -> void:
	var pueblo := Pueblo.de_tabla(7)
	var rng := _rng(11)

	var pregunta := GeneradorOpciones.seleccionar_pregunta(pueblo, rng)
	comprobar("devuelve una pregunta", pregunta != null)
	comprobar("no la marca como respondida", not pregunta.respondida)
	igual("la pregunta es de la tabla del pueblo", 7, pregunta.multiplicando)
	comprobar("el multiplicador esta entre 1 y 10", pregunta.multiplicador >= 1 and pregunta.multiplicador <= 10)

	# Con una sola pregunta pendiente siempre devuelve esa.
	for p in pueblo.preguntas:
		p.respondida = p != pueblo.preguntas[4]
	var siempre_la_misma := true
	for _i in 20:
		siempre_la_misma = (
			siempre_la_misma
			and GeneradorOpciones.seleccionar_pregunta(pueblo, rng) == pueblo.preguntas[4]
		)
	comprobar("elige la unica pendiente", siempre_la_misma)

	for p in pueblo.preguntas:
		p.respondida = true
	comprobar(
		"sin pendientes devuelve null",
		GeneradorOpciones.seleccionar_pregunta(pueblo, rng) == null
	)


func _probar_opciones() -> void:
	var rng := _rng(22)
	var todas_validas := true
	for _i in 100:
		var pregunta := Pregunta.new(7, 8)
		var opciones := GeneradorOpciones._generar_opciones(pregunta, rng, 3)
		todas_validas = (
			todas_validas
			and opciones.size() == 3
			and opciones.has(pregunta.respuesta_literal)
			and _sin_duplicados(opciones)
			and _todas_positivas(opciones)
		)
	comprobar("cien preguntas con tres opciones validas", todas_validas)

	# La respuesta correcta debe caer en las tres posiciones.
	var conteo := [0, 0, 0]
	var rng2 := _rng(33)
	for _i in 1000:
		var pregunta := Pregunta.new(9, 6)
		var opciones := GeneradorOpciones._generar_opciones(pregunta, rng2, 3)
		conteo[opciones.find(pregunta.respuesta_literal)] += 1
	comprobar(
		"la respuesta aparece en las tres posiciones",
		conteo[0] > 250 and conteo[1] > 250 and conteo[2] > 250,
		str(conteo)
	)


func _probar_barajar() -> void:
	var rng := _rng(44)
	var valores: Array[int] = [1, 2, 3, 4, 5]
	GeneradorOpciones._barajar(valores, rng)
	var ordenados := valores.duplicate()
	ordenados.sort()
	igual("barajar conserva los valores", [1, 2, 3, 4, 5], ordenados)

	var uno: Array[int] = [7]
	GeneradorOpciones._barajar(uno, rng)
	igual("barajar un solo valor", [7], uno)


func _rng(semilla: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla
	return rng


func _sin_duplicados(valores: Array[String]) -> bool:
	var vistos := {}
	for valor in valores:
		if vistos.has(valor):
			return false
		vistos[valor] = true
	return true


func _todas_positivas(valores: Array[String]) -> bool:
	for valor in valores:
		if int(valor) <= 0:
			return false
	return true

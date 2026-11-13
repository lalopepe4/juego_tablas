extends PruebaBase

## Pruebas de SelectorJefe: tamano, validez, prioridad y desempates.

const TABLAS: Array[int] = [2, 3, 4, 5, 6, 7, 8, 9, 10]


func _init() -> void:
	nombre = "SelectorJefe"


func ejecutar() -> void:
	_probar_seleccion()
	_probar_prioridad()
	_probar_relleno()
	_probar_desempates()


func _probar_seleccion() -> void:
	var elegidas := SelectorJefe.seleccionar(TABLAS, {}, _rng(7))
	igual("diez preguntas", 10, elegidas.size())
	comprobar("sin duplicados", _claves_unicas(elegidas))
	comprobar("solo tablas pedidas", _tablas_validas(elegidas))
	comprobar("multiplicadores del 1 al 10", _multiplicadores_validos(elegidas))

	var otra := SelectorJefe.seleccionar(TABLAS, {}, _rng(7))
	igual("misma semilla, misma seleccion", _claves(elegidas), _claves(otra))


func _probar_prioridad() -> void:
	var fallos := {}
	for tabla in TABLAS:
		fallos["%d x 3" % tabla] = 5
		fallos["%d x 7" % tabla] = 3

	var elegidas := SelectorJefe.seleccionar(TABLAS, fallos, _rng(1))
	igual("con fallos sigue habiendo diez", 10, elegidas.size())
	comprobar(
		"incluye las nueve preguntas con cinco fallos",
		_incluye(elegidas, _claves_de_multiplicador(3))
	)
	comprobar(
		"las elegidas son las mas falladas",
		_todas_con_fallos(elegidas, fallos, 3)
	)


func _probar_relleno() -> void:
	var parcial := SelectorJefe._elegir_de_tabla(2, {"2 x 5": 1}, _rng(3))
	igual("rellena hasta dos candidatas", 2, parcial.size())
	comprobar("incluye la pregunta fallada", _claves(parcial).has("2 x 5"))
	comprobar("las candidatas no se repiten", _claves_unicas(parcial))


func _probar_desempates() -> void:
	var tablas: Array[Pregunta] = [Pregunta.new(2, 9), Pregunta.new(3, 9)]
	igual(
		"desempata por la tabla menor",
		0,
		SelectorJefe._indice_mas_fallada(tablas, {})
	)

	var multiplicadores: Array[Pregunta] = [Pregunta.new(2, 5), Pregunta.new(2, 9)]
	igual(
		"desempata por el multiplicador mayor",
		1,
		SelectorJefe._indice_mas_fallada(multiplicadores, {})
	)
	igual(
		"prioriza la que mas fallos tiene",
		0,
		SelectorJefe._indice_mas_fallada(multiplicadores, {"2 x 5": 2})
	)


func _rng(semilla: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla
	return rng


func _claves(preguntas: Array[Pregunta]) -> Array[String]:
	var claves: Array[String] = []
	for pregunta in preguntas:
		claves.append(pregunta.clave)
	return claves


func _claves_unicas(preguntas: Array[Pregunta]) -> bool:
	var vistos := {}
	for pregunta in preguntas:
		if vistos.has(pregunta.clave):
			return false
		vistos[pregunta.clave] = true
	return true


func _tablas_validas(preguntas: Array[Pregunta]) -> bool:
	for pregunta in preguntas:
		if not TABLAS.has(pregunta.multiplicando):
			return false
	return true


func _multiplicadores_validos(preguntas: Array[Pregunta]) -> bool:
	for pregunta in preguntas:
		if pregunta.multiplicador < 1 or pregunta.multiplicador > 10:
			return false
	return true


func _incluye(preguntas: Array[Pregunta], claves: Array[String]) -> bool:
	var presentes := {}
	for pregunta in preguntas:
		presentes[pregunta.clave] = true
	for clave in claves:
		if not presentes.has(clave):
			return false
	return true


func _claves_de_multiplicador(multiplicador: int) -> Array[String]:
	var claves: Array[String] = []
	for tabla in TABLAS:
		claves.append("%d x %d" % [tabla, multiplicador])
	return claves


func _todas_con_fallos(
	preguntas: Array[Pregunta], fallos: Dictionary, minimo: int
) -> bool:
	for pregunta in preguntas:
		if int(fallos.get(pregunta.clave, 0)) < minimo:
			return false
	return true

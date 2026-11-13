class_name SelectorJefe
extends RefCounted

## Elige las diez preguntas del jefe final.
##
## Primero toma las dos multiplicaciones con mas fallos de cada tabla. Cuando
## una tabla tiene menos de dos preguntas falladas, completa los huecos al azar
## para que el jefe no pregunte siempre lo mismo. Despues, de esas dieciocho
## candidatas, se queda con las diez que acumulan mas fallos.

const PREGUNTAS_JEFE := 10
const CANDIDATAS_POR_TABLA := 2
const MULTIPLICADORES := 10


static func seleccionar(
	tablas: Array[int], fallos: Dictionary, rng: RandomNumberGenerator
) -> Array[Pregunta]:
	var candidatas: Array[Pregunta] = []
	for tabla in tablas:
		candidatas.append_array(_elegir_de_tabla(tabla, fallos, rng))

	var elegidas: Array[Pregunta] = []
	while elegidas.size() < PREGUNTAS_JEFE and not candidatas.is_empty():
		var indice := _indice_mas_fallada(candidatas, fallos)
		elegidas.append(candidatas[indice])
		candidatas.remove_at(indice)
	return elegidas


static func _elegir_de_tabla(
	tabla: int, fallos: Dictionary, rng: RandomNumberGenerator
) -> Array[Pregunta]:
	var pendientes: Array[Pregunta] = []
	for multiplicador in range(1, MULTIPLICADORES + 1):
		pendientes.append(Pregunta.new(tabla, multiplicador))

	var elegidas: Array[Pregunta] = []
	while elegidas.size() < CANDIDATAS_POR_TABLA and not pendientes.is_empty():
		var indice := _indice_mas_fallada(pendientes, fallos)
		if _fallos_de(pendientes[indice], fallos) > 0:
			elegidas.append(pendientes[indice])
			pendientes.remove_at(indice)
		else:
			# Ninguna de las que quedan tiene fallos: se rellena al azar.
			var azar := rng.randi_range(0, pendientes.size() - 1)
			elegidas.append(pendientes[azar])
			pendientes.remove_at(azar)
	return elegidas


## Indice de la pregunta mas dificil: mas fallos, luego multiplicador mayor y
## por ultimo la tabla menor. El orden fijo hace que el jefe sea reproducible.
static func _indice_mas_fallada(preguntas: Array[Pregunta], fallos: Dictionary) -> int:
	var mejor := 0
	for indice in range(1, preguntas.size()):
		if _es_mas_fallada(preguntas[indice], preguntas[mejor], fallos):
			mejor = indice
	return mejor


static func _es_mas_fallada(a: Pregunta, b: Pregunta, fallos: Dictionary) -> bool:
	var fallos_a := _fallos_de(a, fallos)
	var fallos_b := _fallos_de(b, fallos)
	if fallos_a != fallos_b:
		return fallos_a > fallos_b
	if a.multiplicador != b.multiplicador:
		return a.multiplicador > b.multiplicador
	return a.multiplicando < b.multiplicando


static func _fallos_de(pregunta: Pregunta, fallos: Dictionary) -> int:
	return int(fallos.get(pregunta.clave, 0))

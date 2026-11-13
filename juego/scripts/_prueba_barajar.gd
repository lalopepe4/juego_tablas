extends SceneTree

## Prueba empirica de GeneradorOpciones._barajar.
## La respuesta correcta siempre entra como primer valor del array.

const CORRECTA := 7


func _initialize() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	_probar_barajar(rng, 100)
	_probar_barajar(rng, 10000)
	_probar_generar_opciones(rng, 100)
	quit()


func _probar_barajar(rng: RandomNumberGenerator, pruebas: int) -> void:
	var conteo := [0, 0, 0]
	for _i in range(pruebas):
		var valores: Array[int] = [CORRECTA, 8, 9]
		GeneradorOpciones._barajar(valores, rng)
		conteo[valores.find(CORRECTA)] += 1

	_imprimir("_barajar", pruebas, conteo)


func _probar_generar_opciones(rng: RandomNumberGenerator, pruebas: int) -> void:
	var conteo := [0, 0, 0]
	for _i in range(pruebas):
		var pregunta := Pregunta.new(7, 8)  # respuesta = 56
		var opciones := GeneradorOpciones._generar_opciones(pregunta, rng, 3)
		conteo[opciones.find(pregunta.respuesta_literal)] += 1

	_imprimir("_generar_opciones", pruebas, conteo)


func _imprimir(nombre: String, pruebas: int, conteo: Array) -> void:
	var esperado := float(pruebas) / 3.0
	print("=== %s: %d pruebas (esperado ~%.1f por posicion) ===" % [
		nombre, pruebas, esperado
	])
	print("  Primero: %d" % conteo[0])
	print("  Segundo: %d" % conteo[1])
	print("  Tercero: %d" % conteo[2])

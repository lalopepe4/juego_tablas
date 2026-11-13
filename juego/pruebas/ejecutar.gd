extends SceneTree

## Ejecuta las pruebas headless del proyecto.
##
## Uso:
##   godot --headless --path juego --script res://pruebas/ejecutar.gd
##
## Sale con codigo 0 si todo pasa y 1 si hay algun fallo.

const SUITES := [
	preload("res://pruebas/prueba_generador_opciones.gd"),
	preload("res://pruebas/prueba_batalla.gd"),
	preload("res://pruebas/prueba_selector_jefe.gd"),
	preload("res://pruebas/prueba_progreso.gd"),
	preload("res://pruebas/prueba_navegacion.gd"),
]


func _initialize() -> void:
	_ejecutar.call_deferred()


func _ejecutar() -> void:
	var total := 0
	var fallos := 0
	for suite_script in SUITES:
		var suite: PruebaBase = suite_script.new()
		print("\n== %s ==" % suite.nombre)
		await suite.ejecutar()
		for mensaje in suite.mensajes:
			print(mensaje)
		total += suite.total
		fallos += suite.fallos

	print("\n%d comprobaciones, %d fallos" % [total, fallos])
	if fallos > 0:
		printerr("PRUEBAS FALLIDAS")
		quit(1)
	else:
		print("TODO OK")
		quit(0)

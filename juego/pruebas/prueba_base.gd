class_name PruebaBase
extends RefCounted

## Base minima para las pruebas headless.
##
## Cada suite hereda, define `nombre` y `ejecutar()`, y usa `comprobar()` para
## acumular resultados. El runner `ejecutar.gd` imprime los mensajes y decide
## el codigo de salida del proceso.

var nombre := "Prueba"
var total := 0
var fallos := 0
var mensajes: Array[String] = []


func ejecutar() -> void:
	pass


func comprobar(descripcion: String, condicion: bool, detalle: String = "") -> void:
	total += 1
	if condicion:
		mensajes.append("  OK    " + descripcion)
		return
	fallos += 1
	var sufijo := "" if detalle.is_empty() else " (" + detalle + ")"
	mensajes.append("  FALLO " + descripcion + sufijo)


func igual(descripcion: String, esperado: Variant, obtenido: Variant) -> void:
	comprobar(
		descripcion,
		esperado == obtenido,
		"esperado %s, obtenido %s" % [esperado, obtenido]
	)


func casi_igual(
	descripcion: String, esperado: float, obtenido: float, margen := 0.001
) -> void:
	comprobar(
		descripcion,
		absf(esperado - obtenido) <= margen,
		"esperado %f, obtenido %f" % [esperado, obtenido]
	)

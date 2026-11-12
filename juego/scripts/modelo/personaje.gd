class_name Personaje
extends RefCounted

## Personaje de la batalla: Chispita o un monstruo.

signal vida_changed
signal mensaje_changed(mensaje: String)

const VIDA_MAXIMA := 100

var nombre: String
var ataque := 10

var _vida := VIDA_MAXIMA
var vida: int:
	get:
		return _vida
	set(valor):
		_vida = valor
		vida_changed.emit()

var _mensaje := ""
var mensaje: String:
	get:
		return _mensaje
	set(valor):
		_mensaje = valor
		mensaje_changed.emit(valor)


func _init(p_nombre: String) -> void:
	nombre = p_nombre


func atacar(objetivo: Personaje) -> void:
	objetivo.vida -= ataque
	objetivo.mensaje = "¡Me has atacado!"


func curar(cantidad: int) -> void:
	vida = mini(vida + cantidad, VIDA_MAXIMA)

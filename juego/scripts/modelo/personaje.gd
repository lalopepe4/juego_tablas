class_name Personaje
extends RefCounted

## Personaje de la batalla: Chispita o un monstruo.

signal vida_changed

const VIDA_MAXIMA := 100

var nombre: String
var ataque := 10

var _vida := VIDA_MAXIMA
var vida: int:
	get:
		return _vida
	set(valor):
		_vida = maxi(valor, 0)
		vida_changed.emit()


func _init(p_nombre: String) -> void:
	nombre = p_nombre


func atacar(objetivo: Personaje) -> void:
	objetivo.vida -= ataque


func curar(cantidad: int) -> void:
	vida = mini(vida + cantidad, VIDA_MAXIMA)

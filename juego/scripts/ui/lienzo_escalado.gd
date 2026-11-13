class_name LienzoEscalado
extends Control

## Escala y centra un lienzo de tamano fijo dentro del viewport.
##
## Se asigna al nodo "Lienzo" de cada pantalla. Asi el fondo y los controles
## conservan su posicion relativa en cualquier relacion de aspecto, sin repetir
## el mismo calculo en cada script de pantalla.

@export var tamano := Vector2(1280.0, 720.0)


func _ready() -> void:
	get_viewport().size_changed.connect(_ajustar)
	_ajustar()


func _ajustar() -> void:
	var vista := get_viewport_rect().size
	var escala := minf(vista.x / tamano.x, vista.y / tamano.y)
	scale = Vector2(escala, escala)
	position = (vista - tamano * escala) * 0.5

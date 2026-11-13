class_name AnimadorBatalla
extends Node

## Animaciones de la escena de batalla.
##
## Concentra los tweens y las posiciones de reposo para que `batalla.gd` solo
## decida *cuando* animar. Las referencias a los nodos de `batalla.tscn` se
## ajustan desde el inspector; por defecto apuntan a los hermanos del nodo.

## Tamano de diseno de la escena. Todo se coloca dentro de este lienzo.
const TAMANO_LIENZO := Vector2(1280.0, 720.0)
const DURACION_ENTRADA := 0.9
const DURACION_NUBE := 0.65

@export var sprite_heroe: NodePath = ^"../HeroeSprite"
@export var sprite_enemigo: NodePath = ^"../MonstruoSprite"
@export var barra_heroe: NodePath = ^"../Heroe"
@export var barra_enemigo: NodePath = ^"../Monstruo"
@export var efecto_ataque_heroe: NodePath = ^"../AtaqueHeroe"
@export var efecto_ataque_enemigo: NodePath = ^"../AtaqueEnemigo"
@export var efecto_impacto: NodePath = ^"../Impacto"
@export var nube: NodePath = ^"../Nube"
@export var opciones: NodePath = ^"../Opciones"

var pos_heroe := Vector2.ZERO
var pos_enemigo := Vector2.ZERO
var pos_nube := Vector2.ZERO
var pos_opciones := Vector2.ZERO

var _sprite_heroe: TextureRect
var _sprite_enemigo: TextureRect
var _barra_heroe: Control
var _barra_enemigo: Control
var _efecto_ataque_heroe: TextureRect
var _efecto_ataque_enemigo: TextureRect
var _efecto_impacto: TextureRect
var _nube: TextureRect
var _opciones: Control


func _ready() -> void:
	_sprite_heroe = get_node(sprite_heroe) as TextureRect
	_sprite_enemigo = get_node(sprite_enemigo) as TextureRect
	_barra_heroe = get_node(barra_heroe) as Control
	_barra_enemigo = get_node(barra_enemigo) as Control
	_efecto_ataque_heroe = get_node(efecto_ataque_heroe) as TextureRect
	_efecto_ataque_enemigo = get_node(efecto_ataque_enemigo) as TextureRect
	_efecto_impacto = get_node(efecto_impacto) as TextureRect
	_nube = get_node(nube) as TextureRect
	_opciones = get_node(opciones) as Control
	_preparar()


## Guarda las posiciones de reposo y deja el escenario como antes de entrar.
func _preparar() -> void:
	pos_heroe = _sprite_heroe.position
	pos_enemigo = _sprite_enemigo.position
	pos_nube = _nube.position
	pos_opciones = _opciones.position

	_sprite_heroe.pivot_offset = _sprite_heroe.size * 0.5
	_sprite_enemigo.pivot_offset = _sprite_enemigo.size * 0.5
	for efecto in [_efecto_ataque_heroe, _efecto_ataque_enemigo, _efecto_impacto]:
		efecto.pivot_offset = efecto.size * 0.5
		efecto.visible = false

	_nube.position = _posicion_fuera_de_arriba()
	_nube.modulate.a = 0.0
	_opciones.position = pos_opciones + Vector2(0.0, 24.0)
	_opciones.modulate.a = 0.0
	_barra_heroe.modulate.a = 0.0
	_barra_enemigo.modulate.a = 0.0


func introducir_personajes() -> void:
	_sprite_heroe.position = Vector2(
		-_sprite_heroe.size.x - 40.0, TAMANO_LIENZO.y + 20.0
	)
	_sprite_enemigo.position = Vector2(
		TAMANO_LIENZO.x + 40.0, TAMANO_LIENZO.y + 20.0
	)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(_sprite_heroe, "position", pos_heroe, DURACION_ENTRADA).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		_sprite_enemigo, "position", pos_enemigo, DURACION_ENTRADA
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_barra_heroe, "modulate:a", 1.0, 0.4).set_delay(
		DURACION_ENTRADA * 0.4
	)
	tween.tween_property(_barra_enemigo, "modulate:a", 1.0, 0.4).set_delay(
		DURACION_ENTRADA * 0.4
	)
	await tween.finished


func entrar_nube() -> void:
	_nube.position = _posicion_fuera_de_arriba()
	_nube.modulate.a = 0.0
	_opciones.position = pos_opciones + Vector2(0.0, 24.0)
	_opciones.modulate.a = 0.0

	var tween := create_tween().set_parallel(true)
	tween.tween_property(_nube, "position", pos_nube, DURACION_NUBE).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(_nube, "modulate:a", 1.0, 0.25)
	tween.tween_property(_opciones, "modulate:a", 1.0, 0.3).set_delay(0.25)
	tween.tween_property(_opciones, "position", pos_opciones, 0.35).set_delay(
		0.25
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	await tween.finished


func salir_nube() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_nube, "position", _posicion_fuera_de_arriba(), 0.4).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN)
	tween.tween_property(_nube, "modulate:a", 0.0, 0.3)
	await tween.finished


func ocultar_opciones() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_opciones, "modulate:a", 0.0, 0.2)
	tween.tween_property(
		_opciones, "position", pos_opciones + Vector2(0.0, 20.0), 0.2
	)
	await tween.finished


## Ataque del bando indicado: se lanza hacia el rival y dispara su efecto.
func animar_ataque(es_heroe: bool) -> void:
	var sprite := _sprite_heroe if es_heroe else _sprite_enemigo
	var base := pos_heroe if es_heroe else pos_enemigo
	var direccion := 1.0 if es_heroe else -1.0
	var movimiento := create_tween()
	movimiento.tween_property(
		sprite, "position", base + Vector2(110.0 * direccion, -10.0), 0.16
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	movimiento.tween_property(sprite, "position", base, 0.22).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_IN)
	var efecto := _iniciar_efecto_ataque(es_heroe)
	await movimiento.finished
	if efecto.is_running():
		await efecto.finished
	var efecto_ataque := _efecto_ataque_heroe if es_heroe else _efecto_ataque_enemigo
	efecto_ataque.visible = false
	efecto_ataque.scale = Vector2.ONE
	efecto_ataque.rotation = 0.0


func animar_impacto(es_heroe: bool) -> void:
	var sprite := _sprite_heroe if es_heroe else _sprite_enemigo
	_efecto_impacto.position = sprite.position + (sprite.size - _efecto_impacto.size) * 0.5
	_efecto_impacto.scale = Vector2(0.35, 0.35)
	_efecto_impacto.modulate.a = 1.0
	_efecto_impacto.visible = true
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_efecto_impacto, "scale", Vector2.ONE, 0.18).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(_efecto_impacto, "rotation", 0.2, 0.08).from(-0.2)
	tween.set_parallel(false)
	tween.tween_property(_efecto_impacto, "modulate:a", 0.0, 0.16)
	await tween.finished
	_efecto_impacto.visible = false
	_efecto_impacto.rotation = 0.0


## Sacudida y parpadeo rojo del bando que recibe el dano.
func animar_dano(es_heroe: bool) -> void:
	var sprite := _sprite_heroe if es_heroe else _sprite_enemigo
	var base := pos_heroe if es_heroe else pos_enemigo

	sprite.position = base
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 0.4, 0.4), 0.08)
	for i in 3:
		var desvio := 14.0 if i % 2 == 0 else -14.0
		tween.tween_property(sprite, "position", base + Vector2(desvio, 0.0), 0.05)
	tween.tween_property(sprite, "position", base, 0.06)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.16)
	await tween.finished


## Saca del lienzo al perdedor de la batalla.
func despedir_perdedor(gano_heroe: bool) -> void:
	var sprite := _sprite_enemigo if gano_heroe else _sprite_heroe
	var destino := (
		Vector2(TAMANO_LIENZO.x + 40.0, TAMANO_LIENZO.y + 20.0)
		if gano_heroe
		else Vector2(-sprite.size.x - 40.0, TAMANO_LIENZO.y + 20.0)
	)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(sprite, "position", destino, 0.7).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	await tween.finished


## Lleva al ganador al centro y lo hace saltar tres veces.
func celebrar_ganador(gano_heroe: bool) -> void:
	var sprite := _sprite_heroe if gano_heroe else _sprite_enemigo
	var base := Vector2(
		(TAMANO_LIENZO.x - sprite.size.x) * 0.5,
		pos_heroe.y if gano_heroe else pos_enemigo.y
	)

	var mover := create_tween()
	mover.tween_property(sprite, "position", base, 0.7).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN_OUT)
	await mover.finished

	var celebrar := create_tween()
	for i in 3:
		celebrar.tween_property(sprite, "position:y", base.y - 50.0, 0.22).set_trans(
			Tween.TRANS_QUAD
		).set_ease(Tween.EASE_OUT)
		celebrar.parallel().tween_property(sprite, "scale", Vector2(1.06, 0.94), 0.22)
		celebrar.tween_property(sprite, "position:y", base.y, 0.22).set_trans(
			Tween.TRANS_QUAD
		).set_ease(Tween.EASE_IN)
		celebrar.parallel().tween_property(sprite, "scale", Vector2.ONE, 0.22)
	await celebrar.finished


func ocultar_barras() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_barra_heroe, "modulate:a", 0.0, 0.3)
	tween.tween_property(_barra_enemigo, "modulate:a", 0.0, 0.3)


## Espera ligada al nodo: si la escena se libera, el tween se cancela con ella
## y no queda una corrutina pendiente sobre un objeto inexistente.
func esperar(segundos: float) -> void:
	await create_tween().tween_interval(segundos).finished


func _iniciar_efecto_ataque(es_heroe: bool) -> Tween:
	var efecto := _efecto_ataque_heroe if es_heroe else _efecto_ataque_enemigo
	var origen := _sprite_heroe if es_heroe else _sprite_enemigo
	var destino := _sprite_enemigo if es_heroe else _sprite_heroe
	efecto.texture = Poses.ATAQUE_HEROE if es_heroe else Poses.ATAQUE_ENEMIGO
	var centro_origen := origen.position + origen.size * 0.5
	var centro_destino := destino.position + destino.size * 0.5
	var vector := (centro_destino - centro_origen).normalized()
	efecto.position = centro_origen - efecto.size * 0.5
	efecto.scale = Vector2(0.45, 0.45)
	efecto.rotation = vector.angle()
	efecto.modulate.a = 0.0
	efecto.visible = true

	var tween := create_tween().set_parallel(true)
	tween.tween_property(
		efecto, "position", centro_destino - vector * 85.0 - efecto.size * 0.5, 0.34
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(efecto, "scale", Vector2.ONE, 0.34).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(efecto, "modulate:a", 1.0, 0.08)
	tween.set_parallel(false)
	tween.tween_property(efecto, "modulate:a", 0.0, 0.12)
	return tween


func _posicion_fuera_de_arriba() -> Vector2:
	return Vector2(pos_nube.x, -_nube.size.y - 40.0)

extends Control

## Modo batalla: Chispita responde la tabla del pueblo para derrotar al secuaz.
##
## La logica vive en las clases del modelo (Pregunta, Pueblo, Personaje,
## Batalla y GeneradorOpciones). Este script conecta esa logica con la interfaz
## y usa cada signal del modelo como punto de partida de una animacion.

signal batalla_terminada(victoria: bool, pueblo_id: int)
signal volver_solicitada

const CURACION_BOTIQUIN := 30
const DURACION_ENTRADA := 0.9
const DURACION_NUBE := 0.65
const PAUSA_TRAS_DANO := 0.5
const PAUSA_FINAL := 0.4

## Tamano de diseno de la escena. Todo se coloca dentro de este lienzo.
const TAMANO_LIENZO := Vector2(1280.0, 720.0)

const TEXTURAS := {
	"heroe": {
		"base": preload("res://assets/personajes/heroe_chispita.png"),
		"asustado": preload("res://assets/personajes/heroe_chispita_asustado.png"),
		"concentrado": preload("res://assets/personajes/heroe_chispita_concentrado.png"),
		"satisfecho": preload("res://assets/personajes/heroe_chispita_satisfecho.png"),
		"atacando": preload("res://assets/personajes/heroe_chispita_atacando.png"),
		"sorprendido": preload("res://assets/personajes/heroe_chispita_sorprendido.png"),
		"herido": preload("res://assets/personajes/heroe_chispita_herido.png"),
		"celebrando": preload("res://assets/personajes/heroe_chispita_celebrando.png"),
		"derrotado": preload("res://assets/personajes/heroe_chispita_derrotado.png"),
	},
	"sombras": {
		"base": preload("res://assets/personajes/monstruo_de_sombras.png"),
		"asustado": preload("res://assets/personajes/monstruo_de_sombras_asustado.png"),
		"concentrado": preload("res://assets/personajes/monstruo_de_sombras_concentrado.png"),
		"satisfecho": preload("res://assets/personajes/monstruo_de_sombras_satisfecho.png"),
		"atacando": preload("res://assets/personajes/monstruo_de_sombras_atacando.png"),
		"sorprendido": preload("res://assets/personajes/monstruo_de_sombras_sorprendido.png"),
		"herido": preload("res://assets/personajes/monstruo_de_sombras_herido.png"),
		"celebrando": preload("res://assets/personajes/monstruo_de_sombras_celebrando.png"),
		"derrotado": preload("res://assets/personajes/monstruo_de_sombras_derrotado.png"),
	},
	"secuaz": {
		"base": preload("res://assets/personajes/monstruo_secuaz.png"),
		"asustado": preload("res://assets/personajes/monstruo_secuaz_asustado.png"),
		"concentrado": preload("res://assets/personajes/monstruo_secuaz_concentrado.png"),
		"satisfecho": preload("res://assets/personajes/monstruo_secuaz_satisfecho.png"),
		"atacando": preload("res://assets/personajes/monstruo_secuaz_atacando.png"),
		"sorprendido": preload("res://assets/personajes/monstruo_secuaz_sorprendido.png"),
		"herido": preload("res://assets/personajes/monstruo_secuaz_herido.png"),
		"celebrando": preload("res://assets/personajes/monstruo_secuaz_celebrando.png"),
		"derrotado": preload("res://assets/personajes/monstruo_secuaz_derrotado.png"),
	},
}
const TEXTURA_ATAQUE_HEROE := preload("res://assets/objetos/ataque_chispita.png")
const TEXTURA_ATAQUE_ENEMIGO := preload("res://assets/objetos/ataque_sombra.png")
const TEXTURA_IMPACTO := preload("res://assets/objetos/impacto.png")

const SONIDO_ATAQUE_HEROE := preload("res://assets/sonido/AtaqueHeroe.mp3")
const SONIDO_ATAQUE_SOMBRAS := preload("res://assets/sonido/AtaqueMonstruo.mp3")
const SONIDO_ATAQUE_SECUAZ := preload("res://assets/sonido/AtaqueSecuaz.mp3")
const SONIDO_RESPUESTA_CORRECTA := preload("res://assets/sonido/RespuestaCorrecta.wav")
const SONIDO_RESPUESTA_INCORRECTA := preload("res://assets/sonido/RespuestaIncorrecta.mp3")
const SONIDO_VICTORIA_SECUACES := preload("res://assets/sonido/GanasteBatalla.mp3")
const SONIDO_VICTORIA_FINAL := preload("res://assets/sonido/GanasteUltimaBatalla.mp3")
const SONIDO_DERROTA := preload("res://assets/sonido/PerdisteBatalla.mp3")

var pueblo_id := 0

var _batalla: Batalla
var _heroe: Personaje
var _enemigo: Personaje
var _pueblo: Pueblo
var _rng := RandomNumberGenerator.new()
var _botiquin_disponible := true
var _botiquin_abierto := false
var _botiquin_habilitado := false
var _suma_botiquin: Dictionary = {}
var _respuesta_botiquin := ""
var _pregunta_suspendida: Pregunta
var _sonido_respuesta: AudioStreamPlayer
var _sonido_ataque: AudioStreamPlayer
var _sonido_final: AudioStreamPlayer

var _pos_heroe := Vector2.ZERO
var _pos_monstruo := Vector2.ZERO
var _pos_nube := Vector2.ZERO
var _pos_botiquin := Vector2.ZERO
var _tamano_botiquin := Vector2.ZERO
var _pos_opciones := Vector2.ZERO
var _pantalla := Vector2.ZERO

@onready var _lienzo: Control = $Lienzo
@onready var _volver: Button = $Volver
@onready var _sprite_heroe: TextureRect = $Lienzo/HeroeSprite
@onready var _sprite_monstruo: TextureRect = $Lienzo/MonstruoSprite
@onready var _efecto_ataque_heroe: TextureRect = $Lienzo/AtaqueHeroe
@onready var _efecto_ataque_enemigo: TextureRect = $Lienzo/AtaqueEnemigo
@onready var _efecto_impacto: TextureRect = $Lienzo/Impacto
@onready var _barra_heroe: Control = $Lienzo/Heroe
@onready var _barra_monstruo: Control = $Lienzo/Monstruo
@onready var _nube: TextureRect = $Lienzo/Nube
@onready var _pregunta: Label = $Lienzo/Nube/Pregunta
@onready var _contenedor_opciones: HBoxContainer = $Lienzo/Opciones
@onready var _opciones: Array[Button] = [
	$Lienzo/Opciones/Opcion1, $Lienzo/Opciones/Opcion2, $Lienzo/Opciones/Opcion3
]
@onready var _botiquin: TextureRect = $Lienzo/Botiquin
@onready var _mensaje: Label = $Lienzo/Mensaje
@onready var _pantalla_botiquin: Label = $Lienzo/Botiquin/Pantalla
@onready var _teclado_botiquin: GridContainer = $Lienzo/Botiquin/Teclado
@onready var _teclas_botiquin: Array[Button] = [
	$Lienzo/Botiquin/Teclado/Digito1,
	$Lienzo/Botiquin/Teclado/Digito2,
	$Lienzo/Botiquin/Teclado/Digito3,
	$Lienzo/Botiquin/Teclado/Digito4,
	$Lienzo/Botiquin/Teclado/Digito5,
	$Lienzo/Botiquin/Teclado/Digito6,
	$Lienzo/Botiquin/Teclado/Digito7,
	$Lienzo/Botiquin/Teclado/Digito8,
	$Lienzo/Botiquin/Teclado/Digito9,
	$Lienzo/Botiquin/Teclado/Digito0,
]
@onready var _borrar_botiquin: Button = $Lienzo/Botiquin/Teclado/Borrar
@onready var _confirmar_botiquin: Button = $Lienzo/Botiquin/Teclado/Confirmar


func _ready() -> void:
	_ajustar_lienzo()
	get_viewport().size_changed.connect(_ajustar_lienzo)
	_volver.pressed.connect(_al_pulsar_volver)
	_sonido_respuesta = _crear_reproductor("SonidoRespuesta")
	_sonido_ataque = _crear_reproductor("SonidoAtaque")
	_sonido_final = _crear_reproductor("SonidoFinal")
	_rng.randomize()
	var tabla := clampi(pueblo_id + 1, 1, Progreso.TOTAL_PUEBLOS)
	_pueblo = Pueblo.new(tabla)
	_heroe = Personaje.new("Chispita")
	_enemigo = Personaje.new(
		"Monstruo de Sombras" if pueblo_id == Progreso.TOTAL_PUEBLOS - 1 else "Secuaz"
	)
	_batalla = Batalla.new(_heroe, _enemigo, _pueblo)

	_sprite_monstruo.flip_h = true
	_poner_pose("heroe", "base")
	_poner_pose("enemigo", "base")

	_batalla.pregunta_changed.connect(_al_cambiar_pregunta)
	_batalla.respuesta_changed.connect(_al_cambiar_respuesta)
	_batalla.ganador_changed.connect(_al_cambiar_ganador)
	_heroe.vida_changed.connect(_actualizar_barras)
	_enemigo.vida_changed.connect(_actualizar_barras)

	for indice in _opciones.size():
		_opciones[indice].pressed.connect(_al_responder.bind(indice))
	for tecla in _teclas_botiquin:
		tecla.pressed.connect(_al_pulsar_digito.bind(tecla.text))
	_botiquin.gui_input.connect(_al_pulsar_botiquin)
	_borrar_botiquin.pressed.connect(_al_borrar_botiquin)
	_confirmar_botiquin.pressed.connect(_al_confirmar_botiquin)
	_pantalla_botiquin.visible = false
	_teclado_botiquin.visible = false

	_preparar_escena()
	_actualizar_barras()

	# El escenario empieza vacio: primero entran los personajes, luego el
	# botiquin y solo entonces arranca la logica de la batalla.
	await _introducir_personajes()
	await _introducir_botiquin()
	_batalla.iniciar()


## Escala el lienzo para que quepa entero en la pantalla y lo centra.
## Asi el fondo y todo el contenido conservan la misma posicion relativa,
## aunque la pantalla del movil no sea 16:9.
func _ajustar_lienzo() -> void:
	var vista := get_viewport_rect().size
	var escala := minf(vista.x / TAMANO_LIENZO.x, vista.y / TAMANO_LIENZO.y)
	_lienzo.scale = Vector2(escala, escala)
	_lienzo.position = (vista - TAMANO_LIENZO * escala) * 0.5


func _preparar_escena() -> void:
	_pantalla = TAMANO_LIENZO
	_pos_heroe = _sprite_heroe.position
	_pos_monstruo = _sprite_monstruo.position
	_pos_nube = _nube.position
	_pos_botiquin = _botiquin.position
	_tamano_botiquin = _botiquin.size
	_pos_opciones = _contenedor_opciones.position

	_bloquear_opciones()
	_habilitar_botiquin(false)

	_sprite_heroe.pivot_offset = _sprite_heroe.size * 0.5
	_sprite_monstruo.pivot_offset = _sprite_monstruo.size * 0.5
	for efecto in [_efecto_ataque_heroe, _efecto_ataque_enemigo, _efecto_impacto]:
		efecto.pivot_offset = efecto.size * 0.5
		efecto.visible = false

	_nube.position = Vector2(_pos_nube.x, -_nube.size.y - 40.0)
	_nube.modulate.a = 0.0
	_contenedor_opciones.position = _pos_opciones + Vector2(0.0, 24.0)
	_contenedor_opciones.modulate.a = 0.0
	_botiquin.position = Vector2(_pos_botiquin.x, _pantalla.y + 20.0)
	_botiquin.modulate.a = 0.0
	_barra_heroe.modulate.a = 0.0
	_barra_monstruo.modulate.a = 0.0
	_mensaje.text = ""


func _introducir_personajes() -> void:
	_sprite_heroe.position = Vector2(-_sprite_heroe.size.x - 40.0, _pantalla.y + 20.0)
	_sprite_monstruo.position = Vector2(_pantalla.x + 40.0, _pantalla.y + 20.0)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(_sprite_heroe, "position", _pos_heroe, DURACION_ENTRADA).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		_sprite_monstruo, "position", _pos_monstruo, DURACION_ENTRADA
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_barra_heroe, "modulate:a", 1.0, 0.4).set_delay(
		DURACION_ENTRADA * 0.4
	)
	tween.tween_property(_barra_monstruo, "modulate:a", 1.0, 0.4).set_delay(
		DURACION_ENTRADA * 0.4
	)
	await tween.finished


func _introducir_botiquin() -> void:
	_botiquin.position = Vector2(_pos_botiquin.x, _pantalla.y + 20.0)
	_botiquin.modulate.a = 0.0

	var tween := create_tween().set_parallel(true)
	tween.tween_property(_botiquin, "position", _pos_botiquin, 0.6).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(_botiquin, "modulate:a", 1.0, 0.25)
	await tween.finished


func _al_cambiar_pregunta(pregunta: Pregunta) -> void:
	if pregunta == null:
		_bloquear_opciones()
		_habilitar_botiquin(false)
		return

	_poner_pose("heroe", "concentrado")
	_poner_pose("enemigo", "concentrado")
	_bloquear_opciones()
	_habilitar_botiquin(false)
	_pregunta.text = pregunta.pregunta_literal
	for indice in _opciones.size():
		_opciones[indice].text = pregunta.opciones[indice]
	_mensaje.text = ""

	await _entrar_nube()

	if _botiquin_abierto or _batalla.ganador != null:
		return
	for indice in _opciones.size():
		_opciones[indice].disabled = false
	_habilitar_botiquin(_botiquin_disponible)


func _al_responder(indice: int) -> void:
	if _batalla.pregunta == null or _batalla.ganador != null:
		return

	_bloquear_opciones()
	_habilitar_botiquin(false)
	_batalla.responder(_opciones[indice].text)


func _al_cambiar_respuesta(
	acierto: bool, atacante: Personaje, defensor: Personaje
) -> void:
	if _batalla.pregunta == null:
		return

	if acierto:
		_reproducir_sonido(_sonido_respuesta, SONIDO_RESPUESTA_CORRECTA)
		_mensaje.text = "¡Correcto! La respuesta es %s." % _batalla.pregunta.respuesta_literal
	else:
		_reproducir_sonido(_sonido_respuesta, SONIDO_RESPUESTA_INCORRECTA)
		_mensaje.text = "Fallaste. La respuesta era %s." % _batalla.pregunta.respuesta_literal

	var atacante_lado := "heroe" if atacante == _heroe else "enemigo"
	var defensor_lado := "heroe" if defensor == _heroe else "enemigo"
	_poner_pose(atacante_lado, "satisfecho")
	_poner_pose(defensor_lado, "sorprendido")
	await _ocultar_opciones()
	await _salir_nube()
	await get_tree().create_timer(0.2).timeout
	_poner_pose(atacante_lado, "atacando")
	await _animar_ataque(atacante)
	_batalla.aplicar_dano()
	_poner_pose(defensor_lado, "herido")
	await _animar_impacto(defensor)
	await _animar_dano(defensor)
	await get_tree().create_timer(PAUSA_TRAS_DANO).timeout
	_poner_pose_idle()
	_batalla.avanzar()


func _al_cambiar_ganador(ganador: Personaje) -> void:
	if ganador == null:
		return

	_bloquear_opciones()
	_habilitar_botiquin(false)
	_pantalla_botiquin.visible = false
	_teclado_botiquin.visible = false

	var victoria := ganador == _heroe
	var perdedor_lado := "enemigo" if victoria else "heroe"
	_poner_pose(perdedor_lado, "derrotado")
	if victoria:
		_reproducir_sonido(
			_sonido_final,
			SONIDO_VICTORIA_FINAL
			if pueblo_id == Progreso.TOTAL_PUEBLOS - 1
			else SONIDO_VICTORIA_SECUACES
		)
	else:
		_reproducir_sonido(_sonido_final, SONIDO_DERROTA)
	_mensaje.text = (
		"¡Pueblo liberado!" if victoria else "Chispita se ha quedado sin fuerzas..."
	)

	var barras := create_tween().set_parallel(true)
	barras.tween_property(_barra_heroe, "modulate:a", 0.0, 0.3)
	barras.tween_property(_barra_monstruo, "modulate:a", 0.0, 0.3)

	await _despedir_perdedor(ganador)
	await _celebrar_ganador(ganador)
	await get_tree().create_timer(PAUSA_FINAL).timeout
	batalla_terminada.emit(victoria, pueblo_id)


func _entrar_nube() -> void:
	_nube.position = Vector2(_pos_nube.x, -_nube.size.y - 40.0)
	_nube.modulate.a = 0.0
	_contenedor_opciones.position = _pos_opciones + Vector2(0.0, 24.0)
	_contenedor_opciones.modulate.a = 0.0

	var tween := create_tween().set_parallel(true)
	tween.tween_property(_nube, "position", _pos_nube, DURACION_NUBE).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(_nube, "modulate:a", 1.0, 0.25)
	tween.tween_property(_contenedor_opciones, "modulate:a", 1.0, 0.3).set_delay(0.25)
	tween.tween_property(_contenedor_opciones, "position", _pos_opciones, 0.35).set_delay(
		0.25
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	await tween.finished


func _salir_nube() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(
		_nube, "position", Vector2(_pos_nube.x, -_nube.size.y - 40.0), 0.4
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(_nube, "modulate:a", 0.0, 0.3)
	await tween.finished


func _ocultar_opciones() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_contenedor_opciones, "modulate:a", 0.0, 0.2)
	tween.tween_property(
		_contenedor_opciones, "position", _pos_opciones + Vector2(0.0, 20.0), 0.2
	)
	await tween.finished


func _animar_ataque(atacante: Personaje) -> void:
	var es_heroe := atacante == _heroe
	var sonido_ataque: AudioStream = SONIDO_ATAQUE_HEROE
	if not es_heroe:
		sonido_ataque = (
			SONIDO_ATAQUE_SOMBRAS
			if pueblo_id == Progreso.TOTAL_PUEBLOS - 1
			else SONIDO_ATAQUE_SECUAZ
		)
	_reproducir_sonido(_sonido_ataque, sonido_ataque)
	var sprite := _sprite_heroe if es_heroe else _sprite_monstruo
	var base := _pos_heroe if es_heroe else _pos_monstruo
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
	await efecto.finished
	var efecto_ataque := _efecto_ataque_heroe if es_heroe else _efecto_ataque_enemigo
	efecto_ataque.visible = false
	efecto_ataque.scale = Vector2.ONE
	efecto_ataque.rotation = 0.0


func _iniciar_efecto_ataque(es_heroe: bool) -> Tween:
	var efecto := _efecto_ataque_heroe if es_heroe else _efecto_ataque_enemigo
	var origen := _sprite_heroe if es_heroe else _sprite_monstruo
	var destino := _sprite_monstruo if es_heroe else _sprite_heroe
	efecto.texture = TEXTURA_ATAQUE_HEROE if es_heroe else TEXTURA_ATAQUE_ENEMIGO
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


func _animar_impacto(defensor: Personaje) -> void:
	var sprite := _sprite_heroe if defensor == _heroe else _sprite_monstruo
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


func _animar_dano(defensor: Personaje) -> void:
	var es_heroe := defensor == _heroe
	var sprite := _sprite_heroe if es_heroe else _sprite_monstruo
	var base := _pos_heroe if es_heroe else _pos_monstruo

	sprite.position = base
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 0.4, 0.4), 0.08)
	for i in 3:
		var desvio := 14.0 if i % 2 == 0 else -14.0
		tween.tween_property(sprite, "position", base + Vector2(desvio, 0.0), 0.05)
	tween.tween_property(sprite, "position", base, 0.06)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.16)
	await tween.finished


func _despedir_perdedor(ganador: Personaje) -> void:
	var pierde_heroe := ganador != _heroe
	var sprite := _sprite_heroe if pierde_heroe else _sprite_monstruo
	var destino := (
		Vector2(-sprite.size.x - 40.0, _pantalla.y + 20.0)
		if pierde_heroe
		else Vector2(_pantalla.x + 40.0, _pantalla.y + 20.0)
	)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(sprite, "position", destino, 0.7).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	await tween.finished


func _celebrar_ganador(ganador: Personaje) -> void:
	var gana_heroe := ganador == _heroe
	_poner_pose("heroe" if gana_heroe else "enemigo", "celebrando")
	var sprite := _sprite_heroe if gana_heroe else _sprite_monstruo
	var base := Vector2(
		(_pantalla.x - sprite.size.x) * 0.5,
		_pos_heroe.y if gana_heroe else _pos_monstruo.y
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


func _actualizar_barras() -> void:
	_barra_heroe.set_vida(_heroe.vida, Personaje.VIDA_MAXIMA)
	_barra_monstruo.set_vida(_enemigo.vida, Personaje.VIDA_MAXIMA)


func _poner_pose(lado: String, estado: String) -> void:
	var sprite: TextureRect
	var personaje: String
	if lado == "heroe":
		sprite = _sprite_heroe
		personaje = "heroe"
	else:
		sprite = _sprite_monstruo
		personaje = "sombras" if pueblo_id == Progreso.TOTAL_PUEBLOS - 1 else "secuaz"
	var poses: Dictionary = TEXTURAS[personaje]
	sprite.texture = poses.get(estado, poses["base"])


func _poner_pose_idle() -> void:
	_poner_pose("heroe", "asustado" if _heroe.vida <= 30 else "base")
	_poner_pose("enemigo", "herido" if _enemigo.vida <= 30 else "base")


func _al_pulsar_botiquin(evento: InputEvent) -> void:
	if evento is InputEventMouseButton:
		var clic := evento as InputEventMouseButton
		if clic.button_index == MOUSE_BUTTON_LEFT and clic.pressed:
			_al_abrir_botiquin()


func _al_abrir_botiquin() -> void:
	if not _botiquin_habilitado or _botiquin_abierto or _batalla.ganador != null:
		return

	_botiquin_abierto = true
	_habilitar_botiquin(false)
	_bloquear_opciones()
	_pregunta_suspendida = _batalla.pregunta
	if _pregunta_suspendida != null:
		_batalla.pregunta = null

	for tecla in _teclas_botiquin:
		tecla.disabled = false
	_borrar_botiquin.disabled = false
	_confirmar_botiquin.disabled = false
	_suma_botiquin = GeneradorPreguntas.pregunta_botiquin(_rng)
	_respuesta_botiquin = ""
	_actualizar_pantalla_botiquin()
	_pantalla_botiquin.visible = true
	_teclado_botiquin.visible = true
	_pantalla_botiquin.modulate.a = 0.0
	_teclado_botiquin.modulate.a = 0.0

	await _salir_nube()
	await _ocultar_opciones()

	const TAMANO_ABIERTO := Vector2(620.0, 620.0)
	var posicion_centrada := (_pantalla - TAMANO_ABIERTO) * 0.5
	_botiquin.z_index = 20
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_botiquin, "position", posicion_centrada, 0.55).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(_botiquin, "size", TAMANO_ABIERTO, 0.55).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(_pantalla_botiquin, "modulate:a", 1.0, 0.25).set_delay(0.25)
	tween.tween_property(_teclado_botiquin, "modulate:a", 1.0, 0.25).set_delay(0.3)
	await tween.finished


func _al_pulsar_digito(digito: String) -> void:
	if not _botiquin_abierto:
		return
	if _respuesta_botiquin.length() >= str(_suma_botiquin["correcta"]).length():
		return
	_respuesta_botiquin += digito
	_actualizar_pantalla_botiquin()


func _al_borrar_botiquin() -> void:
	if not _botiquin_abierto:
		return
	_respuesta_botiquin = ""
	_actualizar_pantalla_botiquin()
	await _cerrar_botiquin(false, false)


func _al_confirmar_botiquin() -> void:
	if not _botiquin_abierto:
		return
	var correcta := _respuesta_botiquin == str(_suma_botiquin["correcta"])
	await _cerrar_botiquin(correcta, true)


func _actualizar_pantalla_botiquin() -> void:
	var expresion := "%s =" % _suma_botiquin.get("texto", "")
	_pantalla_botiquin.text = expresion
	if not _respuesta_botiquin.is_empty():
		_pantalla_botiquin.text += " " + _respuesta_botiquin


func _cerrar_botiquin(acierto: bool, evaluar: bool) -> void:
	_botiquin_abierto = false
	_habilitar_botiquin(false)
	for tecla in _teclas_botiquin:
		tecla.disabled = true
	_borrar_botiquin.disabled = true
	_confirmar_botiquin.disabled = true
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_botiquin, "position", _pos_botiquin, 0.45).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_botiquin, "size", _tamano_botiquin, 0.45).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_pantalla_botiquin, "modulate:a", 0.0, 0.18)
	tween.tween_property(_teclado_botiquin, "modulate:a", 0.0, 0.18)
	await tween.finished

	_pantalla_botiquin.visible = false
	_teclado_botiquin.visible = false
	_botiquin.z_index = 0
	if evaluar and acierto:
		_botiquin_disponible = false
		_poner_pose("heroe", "satisfecho")
		_heroe.curar(CURACION_BOTIQUIN)
		_mensaje.text = "¡Botiquín usado! Chispita recupera %d de vida." % CURACION_BOTIQUIN
		await get_tree().create_timer(0.9).timeout
	elif evaluar:
		_mensaje.text = "La suma no es correcta. Puedes volver a intentarlo."
	_poner_pose("heroe", "concentrado")

	if _batalla.ganador == null and _pregunta_suspendida != null:
		var pregunta_guardada := _pregunta_suspendida
		_pregunta_suspendida = null
		_batalla.pregunta = pregunta_guardada
	else:
		_habilitar_botiquin(_botiquin_disponible)


func _bloquear_opciones() -> void:
	for boton in _opciones:
		boton.disabled = true


func _habilitar_botiquin(habilitado: bool) -> void:
	_botiquin_habilitado = habilitado
	_botiquin.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND if habilitado else Control.CURSOR_ARROW
	)


func _crear_reproductor(nombre: String) -> AudioStreamPlayer:
	var reproductor := AudioStreamPlayer.new()
	reproductor.name = nombre
	add_child(reproductor)
	return reproductor


func _reproducir_sonido(reproductor: AudioStreamPlayer, sonido: AudioStream) -> void:
	reproductor.stream = sonido
	reproductor.play()


func _al_pulsar_volver() -> void:
	volver_solicitada.emit()

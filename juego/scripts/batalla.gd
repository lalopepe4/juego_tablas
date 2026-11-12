extends Control

## Modo batalla: Chispita responde la tabla del pueblo para derrotar al secuaz.
##
## La logica vive en las clases del modelo (Pregunta, Pueblo, Personaje,
## Batalla y GeneradorOpciones). Este script conecta esa logica con la interfaz
## y usa cada signal del modelo como punto de partida de una animacion.

signal batalla_terminada(victoria: bool, pueblo_id: int)

const CURACION_BOTIQUIN := 30
const DURACION_ENTRADA := 0.9
const DURACION_NUBE := 0.65
const PAUSA_TRAS_DANO := 0.5
const PAUSA_FINAL := 0.4

const TEXTURA_HEROE := preload("res://assets/personajes/heroe_chispita.png")
const TEXTURA_HEROE_ASUSTADO := preload(
	"res://assets/personajes/heroe_chispita_asustado.png"
)
const TEXTURA_SECUAZ := preload("res://assets/personajes/monstruo_secuaz.png")
const TEXTURA_SOMBRAS := preload("res://assets/personajes/monstruo_de_sombras.png")

var pueblo_id := 0

var _batalla: Batalla
var _heroe: Personaje
var _enemigo: Personaje
var _pueblo: Pueblo
var _rng := RandomNumberGenerator.new()
var _botiquin_disponible := true
var _suma_botiquin: Dictionary = {}

var _pos_heroe := Vector2.ZERO
var _pos_monstruo := Vector2.ZERO
var _pos_nube := Vector2.ZERO
var _pos_botiquin := Vector2.ZERO
var _pos_opciones := Vector2.ZERO
var _pantalla := Vector2.ZERO

@onready var _sprite_heroe: TextureRect = $HeroeSprite
@onready var _sprite_monstruo: TextureRect = $MonstruoSprite
@onready var _barra_heroe: Control = $Heroe
@onready var _barra_monstruo: Control = $Monstruo
@onready var _nube: TextureRect = $Nube
@onready var _pregunta: Label = $Nube/Pregunta
@onready var _contenedor_opciones: HBoxContainer = $Opciones
@onready var _opciones: Array[Button] = [
	$Opciones/Opcion1, $Opciones/Opcion2, $Opciones/Opcion3
]
@onready var _botiquin: Button = $Botiquin
@onready var _mensaje: Label = $Mensaje
@onready var _panel_botiquin: PanelContainer = $BotiquinPanel
@onready var _suma: Label = $BotiquinPanel/VBox/Suma
@onready var _respuesta: LineEdit = $BotiquinPanel/VBox/Respuesta
@onready var _confirmar: Button = $BotiquinPanel/VBox/Confirmar


func _ready() -> void:
	_rng.randomize()
	var tabla := clampi(pueblo_id + 1, 1, Progreso.TOTAL_PUEBLOS)
	_pueblo = Pueblo.new(tabla)
	_heroe = Personaje.new("Chispita")
	_enemigo = Personaje.new(
		"Monstruo de Sombras" if pueblo_id == Progreso.TOTAL_PUEBLOS - 1 else "Secuaz"
	)
	_batalla = Batalla.new(_heroe, _enemigo, _pueblo)

	_sprite_monstruo.texture = (
		TEXTURA_SOMBRAS if pueblo_id == Progreso.TOTAL_PUEBLOS - 1 else TEXTURA_SECUAZ
	)

	_batalla.pregunta_changed.connect(_al_cambiar_pregunta)
	_batalla.respuesta_changed.connect(_al_cambiar_respuesta)
	_batalla.ganador_changed.connect(_al_cambiar_ganador)
	_heroe.vida_changed.connect(_actualizar_barras)
	_enemigo.vida_changed.connect(_actualizar_barras)

	for indice in _opciones.size():
		_opciones[indice].pressed.connect(_al_responder.bind(indice))
	_botiquin.pressed.connect(_al_abrir_botiquin)
	_confirmar.pressed.connect(_al_confirmar_botiquin)
	_respuesta.text_submitted.connect(_al_confirmar_botiquin.unbind(1))
	_panel_botiquin.visible = false

	_preparar_escena()
	_actualizar_barras()

	# El escenario empieza vacio: primero entran los personajes, luego el
	# botiquin y solo entonces arranca la logica de la batalla.
	await _introducir_personajes()
	await _introducir_botiquin()
	_batalla.iniciar()


func _preparar_escena() -> void:
	_pantalla = get_viewport_rect().size
	_pos_heroe = _sprite_heroe.position
	_pos_monstruo = _sprite_monstruo.position
	_pos_nube = _nube.position
	_pos_botiquin = _botiquin.position
	_pos_opciones = _contenedor_opciones.position

	_bloquear_opciones()
	_botiquin.disabled = true

	_sprite_heroe.pivot_offset = _sprite_heroe.size * 0.5
	_sprite_monstruo.pivot_offset = _sprite_monstruo.size * 0.5

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
		return

	_bloquear_opciones()
	_botiquin.disabled = true
	_pregunta.text = pregunta.pregunta_literal
	for indice in _opciones.size():
		_opciones[indice].text = pregunta.opciones[indice]
	_mensaje.text = ""

	await _entrar_nube()

	if _panel_botiquin.visible or _batalla.ganador != null:
		return
	for indice in _opciones.size():
		_opciones[indice].disabled = false
	_botiquin.disabled = not _botiquin_disponible


func _al_responder(indice: int) -> void:
	if _batalla.pregunta == null or _batalla.ganador != null:
		return

	_bloquear_opciones()
	_botiquin.disabled = true
	_batalla.responder(_opciones[indice].text)


func _al_cambiar_respuesta(
	acierto: bool, atacante: Personaje, defensor: Personaje
) -> void:
	if _batalla.pregunta == null:
		return

	if acierto:
		_mensaje.text = "¡Correcto! La respuesta es %s." % _batalla.pregunta.respuesta_literal
	else:
		_mensaje.text = "Fallaste. La respuesta era %s." % _batalla.pregunta.respuesta_literal

	_ocultar_opciones()
	await _salir_nube()
	await _animar_ataque(atacante)
	_batalla.aplicar_dano()
	await _animar_dano(defensor)
	await get_tree().create_timer(PAUSA_TRAS_DANO).timeout
	_batalla.avanzar()


func _al_cambiar_ganador(ganador: Personaje) -> void:
	if ganador == null:
		return

	_bloquear_opciones()
	_botiquin.disabled = true
	_panel_botiquin.visible = false

	var victoria := ganador == _heroe
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


func _animar_ataque(atacante: Personaje) -> void:
	var es_heroe := atacante == _heroe
	var sprite := _sprite_heroe if es_heroe else _sprite_monstruo
	var base := _pos_heroe if es_heroe else _pos_monstruo
	var direccion := 1.0 if es_heroe else -1.0

	var tween := create_tween()
	tween.tween_property(
		sprite, "position", base + Vector2(110.0 * direccion, -10.0), 0.16
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position", base, 0.22).set_trans(
		Tween.TRANS_QUAD
	).set_ease(Tween.EASE_IN)
	await tween.finished


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
	_sprite_heroe.texture = (
		TEXTURA_HEROE_ASUSTADO if _heroe.vida <= 30 else TEXTURA_HEROE
	)


func _al_abrir_botiquin() -> void:
	if not _botiquin_disponible:
		return
	_bloquear_opciones()
	_suma_botiquin = GeneradorPreguntas.pregunta_botiquin(_rng)
	_suma.text = _suma_botiquin["texto"]
	_respuesta.text = ""
	_panel_botiquin.visible = true
	_respuesta.grab_focus()


func _al_confirmar_botiquin() -> void:
	if not _panel_botiquin.visible:
		return
	_panel_botiquin.visible = false
	var valor := _respuesta.text.strip_edges().to_int()
	if valor == _suma_botiquin["correcta"]:
		_botiquin_disponible = false
		_botiquin.disabled = true
		_heroe.curar(CURACION_BOTIQUIN)
		_mensaje.text = "¡Botiquín usado! Chispita recupera %d de vida." % CURACION_BOTIQUIN
	else:
		_mensaje.text = "Suma incorrecta: el botiquín sigue cerrado."
	if _batalla.ganador == null and _batalla.pregunta != null:
		for boton in _opciones:
			boton.disabled = false


func _bloquear_opciones() -> void:
	for boton in _opciones:
		boton.disabled = true

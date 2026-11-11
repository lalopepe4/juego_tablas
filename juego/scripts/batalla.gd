extends Control

## Modo batalla: Chispita responde la tabla del pueblo para derrotar al secuaz.
##
## Diez preguntas por batalla. Cada acierto quita vida al monstruo y cada fallo
## se la quita a Chispita. El botiquin cura una sola vez, y solo si el jugador
## resuelve la suma de tres cifras.

signal batalla_terminada(victoria: bool, pueblo_id: int)

const VIDA_MAXIMA := 100
const DANO_ACIERTO := 10
const DANO_FALLO := 10
const CURACION_BOTIQUIN := 30
const ESPERA_ENTRE_PREGUNTAS := 1.2
const ESPERA_FINAL := 1.5

var pueblo_id := 0

var _vida_heroe := VIDA_MAXIMA
var _vida_monstruo := VIDA_MAXIMA
var _preguntas_restantes := GeneradorPreguntas.PREGUNTAS_POR_BATALLA
var _pregunta_actual: Dictionary = {}
var _suma_botiquin: Dictionary = {}
var _botiquin_disponible := true
var _rng := RandomNumberGenerator.new()

@onready var _barra_heroe: Control = $Heroe
@onready var _barra_monstruo: Control = $Monstruo
@onready var _pregunta: Label = $Nube/Pregunta
@onready var _opciones := [$Opciones/Opcion1, $Opciones/Opcion2, $Opciones/Opcion3]
@onready var _botiquin: Button = $Botiquin
@onready var _mensaje: Label = $Mensaje
@onready var _panel_botiquin: PanelContainer = $BotiquinPanel
@onready var _suma: Label = $BotiquinPanel/VBox/Suma
@onready var _respuesta: LineEdit = $BotiquinPanel/VBox/Respuesta
@onready var _confirmar: Button = $BotiquinPanel/VBox/Confirmar


func _ready() -> void:
	_rng.randomize()
	_barra_heroe.set_vida(_vida_heroe, VIDA_MAXIMA)
	_barra_monstruo.set_vida(_vida_monstruo, VIDA_MAXIMA)
	for indice in _opciones.size():
		_opciones[indice].pressed.connect(_al_responder.bind(indice))
	_botiquin.pressed.connect(_al_abrir_botiquin)
	_confirmar.pressed.connect(_al_confirmar_botiquin)
	_respuesta.text_submitted.connect(_al_confirmar_botiquin.unbind(1))
	_panel_botiquin.visible = false
	_siguiente_pregunta()


func _siguiente_pregunta() -> void:
	_pregunta_actual = GeneradorPreguntas.pregunta_tabla(Progreso.tabla_actual, _rng)
	_pregunta.text = _pregunta_actual["texto"]
	var opciones: Array = _pregunta_actual["opciones"]
	for indice in _opciones.size():
		_opciones[indice].text = str(opciones[indice])
		_opciones[indice].disabled = false


func _al_responder(indice: int) -> void:
	var opciones: Array = _pregunta_actual["opciones"]
	var acerto: bool = opciones[indice] == _pregunta_actual["correcta"]
	_bloquear_opciones()
	_preguntas_restantes -= 1
	if acerto:
		_vida_monstruo = maxi(_vida_monstruo - DANO_ACIERTO, 0)
		_barra_monstruo.set_vida(_vida_monstruo, VIDA_MAXIMA)
		_mensaje.text = "¡Correcto! Chispita lanza su rayo mágico."
	else:
		_vida_heroe = maxi(_vida_heroe - DANO_FALLO, 0)
		_barra_heroe.set_vida(_vida_heroe, VIDA_MAXIMA)
		_mensaje.text = "Fallaste. La respuesta era %d." % _pregunta_actual["correcta"]
	await get_tree().create_timer(ESPERA_ENTRE_PREGUNTAS).timeout
	if _vida_heroe <= 0:
		await _terminar(false)
	elif _preguntas_restantes <= 0:
		await _terminar(true)
	else:
		_siguiente_pregunta()


func _al_abrir_botiquin() -> void:
	if not _botiquin_disponible:
		return
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
		_vida_heroe = mini(_vida_heroe + CURACION_BOTIQUIN, VIDA_MAXIMA)
		_barra_heroe.set_vida(_vida_heroe, VIDA_MAXIMA)
		_mensaje.text = "¡Botiquín usado! Chispita recupera %d de vida." % CURACION_BOTIQUIN
	else:
		_mensaje.text = "Suma incorrecta: el botiquín sigue cerrado."


func _bloquear_opciones() -> void:
	for boton in _opciones:
		boton.disabled = true


func _terminar(victoria: bool) -> void:
	_bloquear_opciones()
	_botiquin.disabled = true
	_panel_botiquin.visible = false
	_mensaje.text = "¡Pueblo liberado!" if victoria else "Chispita se ha quedado sin fuerzas..."
	await get_tree().create_timer(ESPERA_FINAL).timeout
	batalla_terminada.emit(victoria, pueblo_id)

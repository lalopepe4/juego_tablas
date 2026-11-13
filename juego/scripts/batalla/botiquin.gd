class_name Botiquin
extends TextureRect

## Botiquin de ayuda: al pulsarlo pide una suma y cura a Chispita si acierta.
##
## Gestiona su propio teclado y sus animaciones. La batalla decide cuando se
## puede usar, aplica la curacion y restaura la pregunta que quedo en pausa.

## Se ha pulsado el botiquin cerrado.
signal solicitado
## El jugador ha pulsado "Borrar": se cierra sin evaluar la respuesta.
signal cancelado
## El jugador ha pulsado "OK" con el resultado de la suma.
signal resuelto(acierto: bool)

const TAMANO_ABIERTO := Vector2(620.0, 620.0)
const TAMANO_LIENZO := Vector2(1280.0, 720.0)

var abierto := false
var habilitado := false

var _posicion_cerrada := Vector2.ZERO
var _tamano_cerrado := Vector2.ZERO
var _suma: Dictionary = {}
var _respuesta := ""

@onready var _pantalla: Label = $Pantalla
@onready var _teclado: GridContainer = $Teclado
@onready var _teclas: Array[Button] = [
	$Teclado/Digito1,
	$Teclado/Digito2,
	$Teclado/Digito3,
	$Teclado/Digito4,
	$Teclado/Digito5,
	$Teclado/Digito6,
	$Teclado/Digito7,
	$Teclado/Digito8,
	$Teclado/Digito9,
	$Teclado/Digito0,
]
@onready var _borrar: Button = $Teclado/Borrar
@onready var _confirmar: Button = $Teclado/Confirmar


func _ready() -> void:
	_posicion_cerrada = position
	_tamano_cerrado = size
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	_pantalla.visible = false
	_teclado.visible = false
	_habilitar_teclado(false)
	for tecla in _teclas:
		tecla.pressed.connect(_al_pulsar_digito.bind(tecla.text))
	_borrar.pressed.connect(_al_borrar)
	_confirmar.pressed.connect(_al_confirmar)
	gui_input.connect(_al_pulsar)
	ocultar()


## Deja el botiquin fuera del lienzo y transparente.
func ocultar() -> void:
	position = Vector2(_posicion_cerrada.x, TAMANO_LIENZO.y + 20.0)
	modulate.a = 0.0


## Entra desde fuera del lienzo al empezar la batalla.
func introducir() -> void:
	ocultar()
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position", _posicion_cerrada, 0.6).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.25)
	await tween.finished


## Se agranda en el centro del lienzo y muestra una suma nueva.
func abrir(rng: RandomNumberGenerator) -> void:
	abierto = true
	_habilitar_teclado(true)
	_suma = GeneradorPreguntas.pregunta_botiquin(rng)
	_respuesta = ""
	_actualizar_pantalla()
	_pantalla.visible = true
	_teclado.visible = true
	_pantalla.modulate.a = 0.0
	_teclado.modulate.a = 0.0

	z_index = 20
	var posicion_abierta := (TAMANO_LIENZO - TAMANO_ABIERTO) * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position", posicion_abierta, 0.55).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "size", TAMANO_ABIERTO, 0.55).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(_pantalla, "modulate:a", 1.0, 0.25).set_delay(0.25)
	tween.tween_property(_teclado, "modulate:a", 1.0, 0.25).set_delay(0.3)
	await tween.finished


## Vuelve a su sitio y oculta el teclado.
func cerrar() -> void:
	abierto = false
	_habilitar_teclado(false)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position", _posicion_cerrada, 0.45).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "size", _tamano_cerrado, 0.45).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_pantalla, "modulate:a", 0.0, 0.18)
	tween.tween_property(_teclado, "modulate:a", 0.0, 0.18)
	await tween.finished

	_pantalla.visible = false
	_teclado.visible = false
	z_index = 0


## Esconde el teclado sin animar, por ejemplo si la batalla ya ha terminado.
func ocultar_controles() -> void:
	_pantalla.visible = false
	_teclado.visible = false
	_habilitar_teclado(false)


func habilitar(valor: bool) -> void:
	habilitado = valor
	mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND if valor else Control.CURSOR_ARROW
	)


func _al_pulsar(evento: InputEvent) -> void:
	if not habilitado or abierto:
		return
	if evento is InputEventMouseButton:
		var clic := evento as InputEventMouseButton
		if clic.button_index == MOUSE_BUTTON_LEFT and clic.pressed:
			solicitado.emit()


func _al_pulsar_digito(digito: String) -> void:
	if not abierto:
		return
	if _respuesta.length() >= str(_suma["correcta"]).length():
		return
	_respuesta += digito
	_actualizar_pantalla()


func _al_borrar() -> void:
	if not abierto:
		return
	_respuesta = ""
	_actualizar_pantalla()
	cancelado.emit()


func _al_confirmar() -> void:
	if not abierto:
		return
	resuelto.emit(_respuesta == str(_suma["correcta"]))


func _actualizar_pantalla() -> void:
	_pantalla.text = "%s =" % _suma.get("texto", "")
	if not _respuesta.is_empty():
		_pantalla.text += " " + _respuesta


func _habilitar_teclado(activo: bool) -> void:
	for tecla in _teclas:
		tecla.disabled = not activo
	_borrar.disabled = not activo
	_confirmar.disabled = not activo

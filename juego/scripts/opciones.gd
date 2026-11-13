extends Control

## Pantalla de opciones: control de tiempo de uso y borrado del progreso.

signal volver_solicitada

const TAMANO_LIENZO := Vector2(1280.0, 720.0)

@onready var _lienzo: Control = $Lienzo
@onready var _activar: CheckButton = $Lienzo/Panel/Margen/Contenido/ControlTiempo/Activar
@onready var _minutos: HSlider = $Lienzo/Panel/Margen/Contenido/ControlTiempo/Minutos
@onready var _etiqueta_minutos: Label = (
	$Lienzo/Panel/Margen/Contenido/ControlTiempo/EtiquetaMinutos
)
@onready var _limpiar: Button = $Lienzo/Panel/Margen/Contenido/Limpiar
@onready var _mensaje: Label = $Lienzo/Panel/Margen/Contenido/Mensaje
@onready var _volver: Button = $Lienzo/Panel/Margen/Contenido/Volver
@onready var _confirmacion: Control = $Lienzo/Confirmacion
@onready var _confirmar_si: Button = (
	$Lienzo/Confirmacion/Panel/Margen/Contenido/Botones/Si
)
@onready var _confirmar_no: Button = (
	$Lienzo/Confirmacion/Panel/Margen/Contenido/Botones/No
)


func _ready() -> void:
	_ajustar_lienzo()
	get_viewport().size_changed.connect(_ajustar_lienzo)
	_activar.button_pressed = ControlTiempo.activo
	_minutos.value = ControlTiempo.minutos
	_actualizar_controles()
	_activar.toggled.connect(_al_cambiar_activo)
	_minutos.value_changed.connect(_al_cambiar_minutos)
	_limpiar.pressed.connect(_al_pulsar_limpiar)
	_volver.pressed.connect(_al_pulsar_volver)
	_confirmar_si.pressed.connect(_al_confirmar_limpiar)
	_confirmar_no.pressed.connect(_cerrar_confirmacion)
	_confirmacion.visible = false
	_mensaje.text = ""


## Escala el lienzo para que quepa entero en la pantalla y lo centra.
func _ajustar_lienzo() -> void:
	var vista := get_viewport_rect().size
	var escala := minf(vista.x / TAMANO_LIENZO.x, vista.y / TAMANO_LIENZO.y)
	_lienzo.scale = Vector2(escala, escala)
	_lienzo.position = (vista - TAMANO_LIENZO * escala) * 0.5


func _actualizar_controles() -> void:
	var activo := _activar.button_pressed
	_minutos.editable = activo
	_etiqueta_minutos.modulate.a = 1.0 if activo else 0.45
	_etiqueta_minutos.text = "%d minutos" % int(_minutos.value)


func _al_cambiar_activo(activo: bool) -> void:
	ControlTiempo.configurar(activo, int(_minutos.value))
	_actualizar_controles()


func _al_cambiar_minutos(valor: float) -> void:
	ControlTiempo.configurar(_activar.button_pressed, int(valor))
	_actualizar_controles()


func _al_pulsar_limpiar() -> void:
	_mensaje.text = ""
	_confirmacion.visible = true


func _cerrar_confirmacion() -> void:
	_confirmacion.visible = false


func _al_confirmar_limpiar() -> void:
	Progreso.reiniciar()
	_confirmacion.visible = false
	_mensaje.text = "Progreso borrado"


func _al_pulsar_volver() -> void:
	volver_solicitada.emit()

extends Control

## Pantalla de opciones: control de tiempo, sonido, modo entrenamiento y
## borrado del progreso.

signal volver_solicitada

## Retraso para no escribir el archivo de configuracion en cada tick del slider.
const ESPERA_GUARDADO := 0.4

@onready var _activar: CheckButton = $Lienzo/Panel/Margen/Contenido/ControlTiempo/Activar
@onready var _minutos: HSlider = $Lienzo/Panel/Margen/Contenido/ControlTiempo/Minutos
@onready var _etiqueta_minutos: Label = (
	$Lienzo/Panel/Margen/Contenido/ControlTiempo/EtiquetaMinutos
)
@onready var _sonido: CheckButton = $Lienzo/Panel/Margen/Contenido/Sonido
@onready var _entrenamiento: CheckButton = $Lienzo/Panel/Margen/Contenido/Entrenamiento
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

var _guardado_diferido: Timer


func _ready() -> void:
	_minutos.min_value = ControlTiempo.MIN_MINUTOS
	_minutos.max_value = ControlTiempo.MAX_MINUTOS
	_activar.button_pressed = ControlTiempo.activo
	_minutos.value = ControlTiempo.minutos
	_sonido.button_pressed = Ajustes.sonido_activo
	_entrenamiento.button_pressed = Ajustes.modo_entrenamiento
	_actualizar_controles()
	_guardado_diferido = Timer.new()
	_guardado_diferido.one_shot = true
	_guardado_diferido.wait_time = ESPERA_GUARDADO
	_guardado_diferido.timeout.connect(ControlTiempo.guardar)
	add_child(_guardado_diferido)
	_activar.toggled.connect(_al_cambiar_activo)
	_minutos.value_changed.connect(_al_cambiar_minutos)
	_sonido.toggled.connect(_al_cambiar_sonido)
	_entrenamiento.toggled.connect(_al_cambiar_entrenamiento)
	_limpiar.pressed.connect(_al_pulsar_limpiar)
	_volver.pressed.connect(_al_pulsar_volver)
	_confirmar_si.pressed.connect(_al_confirmar_limpiar)
	_confirmar_no.pressed.connect(_cerrar_confirmacion)
	_confirmacion.visible = false
	_mensaje.text = ""


func _exit_tree() -> void:
	if _guardado_diferido != null and not _guardado_diferido.is_stopped():
		ControlTiempo.guardar()


func _actualizar_controles() -> void:
	var activo := _activar.button_pressed
	_minutos.editable = activo
	_etiqueta_minutos.modulate.a = 1.0 if activo else 0.45
	_etiqueta_minutos.text = "%d minutos" % int(_minutos.value)


func _al_cambiar_activo(activo: bool) -> void:
	ControlTiempo.configurar(activo, int(_minutos.value))
	ControlTiempo.guardar()
	_actualizar_controles()


func _al_cambiar_minutos(valor: float) -> void:
	ControlTiempo.configurar(_activar.button_pressed, int(valor))
	_actualizar_controles()
	_guardado_diferido.start()


func _al_cambiar_sonido(activo: bool) -> void:
	Ajustes.establecer_sonido(activo)


func _al_cambiar_entrenamiento(activo: bool) -> void:
	Ajustes.establecer_entrenamiento(activo)


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
	_guardado_diferido.stop()
	ControlTiempo.guardar()
	volver_solicitada.emit()


## Boton atras de Android: cierra la confirmacion o vuelve al mapa.
func solicitar_atras() -> void:
	if _confirmacion.visible:
		_cerrar_confirmacion()
	else:
		_al_pulsar_volver()

extends Control

## Diez marcadores colocados en el editor sobre las casas del mapa.
## Cada marcador inicia su batalla; los liberados permiten repasar la tabla.

signal batalla_solicitada(pueblo_id: int, repaso: bool)
signal opciones_solicitada

const ICONO_SECUAZ := preload("res://assets/personajes/monstruo_secuaz_frente.png")
const ICONO_SOMBRAS := preload("res://assets/personajes/monstruo_de_sombras_frente.png")
const ICONO_SECUAZ_DERROTADO := preload(
	"res://assets/personajes/monstruo_secuaz_derrotado.png"
)
const ICONO_SOMBRAS_DERROTADO := preload(
	"res://assets/personajes/monstruo_de_sombras_derrotado.png"
)

@onready var _pueblos: Control = $Lienzo/Pueblos
@onready var _opciones: Button = $Opciones
@onready var _salir: Button = $Salir
@onready var _confirmacion_salir: Control = $Confirmacion
@onready var _confirmar_salir: Button = $Confirmacion/Panel/Margen/Contenido/Botones/Si
@onready var _cancelar_salir: Button = $Confirmacion/Panel/Margen/Contenido/Botones/No
@onready var _aviso_jefe: Control = $AvisoJefe
@onready var _aceptar_aviso: Button = $AvisoJefe/Panel/Margen/Contenido/Aceptar
@onready var _tabla: Control = $Tabla
@onready var _tabla_titulo: Label = $Tabla/Panel/Margen/Contenido/Titulo
@onready var _tabla_filas: GridContainer = $Tabla/Panel/Margen/Contenido/Filas
@onready var _aceptar_tabla: Button = $Tabla/Panel/Margen/Contenido/Botones/Aceptar
@onready var _volver_tabla: Button = $Tabla/Panel/Margen/Contenido/Botones/Volver

var _pueblo_pendiente := 0
var _repaso_pendiente := false


func _ready() -> void:
	_opciones.pressed.connect(_al_pulsar_opciones)
	_salir.pressed.connect(_al_pulsar_salir)
	_confirmar_salir.pressed.connect(_al_confirmar_salir)
	_cancelar_salir.pressed.connect(_cerrar_confirmacion)
	_confirmacion_salir.visible = false
	_aceptar_aviso.pressed.connect(_cerrar_aviso_jefe)
	_aviso_jefe.visible = false
	_aceptar_tabla.pressed.connect(_al_aceptar_tabla)
	_volver_tabla.pressed.connect(_cerrar_tabla)
	_tabla.visible = false
	for pueblo_id in Progreso.TOTAL_PUEBLOS:
		var boton := _obtener_boton(pueblo_id)
		boton.pressed.connect(_al_pulsar_pueblo.bind(pueblo_id))
	_actualizar_botones()


func _obtener_boton(pueblo_id: int) -> Button:
	return _pueblos.get_node("Pueblo%d" % (pueblo_id + 1)) as Button


func _actualizar_botones() -> void:
	for pueblo_id in Progreso.TOTAL_PUEBLOS:
		var boton := _obtener_boton(pueblo_id)
		var es_jefe := pueblo_id == Progreso.PUEBLO_JEFE
		if Progreso.esta_liberado(pueblo_id):
			boton.disabled = false
			boton.modulate = Color(1.0, 1.0, 1.0, 0.9)
			# El monstruo derrotado distingue los pueblos liberados.
			boton.icon = (
				ICONO_SOMBRAS_DERROTADO if es_jefe else ICONO_SECUAZ_DERROTADO
			)
			boton.tooltip_text = (
				"Pueblo %d liberado (pulsa para repasar)" % (pueblo_id + 1)
			)
			boton.text = "Pueblo %d\nliberado" % (pueblo_id + 1)
		elif es_jefe and not Progreso.jefe_desbloqueado():
			# El jefe se ve, pero apagado: al pulsarlo avisa de que aun no toca.
			boton.disabled = false
			boton.modulate = Color(1.0, 1.0, 1.0, 0.8)
			boton.icon = ICONO_SOMBRAS
			boton.tooltip_text = (
				"Libera los nueve pueblos para enfrentarte al Monstruo de Sombras"
			)
			boton.text = "Pueblo %d\nbloqueado" % (pueblo_id + 1)
		else:
			boton.disabled = false
			boton.modulate = Color.WHITE
			boton.icon = ICONO_SOMBRAS if es_jefe else ICONO_SECUAZ
			if es_jefe:
				boton.tooltip_text = (
					"Monstruo de Sombras conquista Pueblo %d" % (pueblo_id + 1)
				)
			else:
				boton.tooltip_text = (
					"Secuaz conquista Pueblo %d (tabla del %d)"
					% [pueblo_id + 1, Progreso.tabla_del_pueblo(pueblo_id)]
				)
			boton.text = "Pueblo %d\nconquistado" % (pueblo_id + 1)


func _al_pulsar_pueblo(pueblo_id: int) -> void:
	if pueblo_id == Progreso.PUEBLO_JEFE and not Progreso.jefe_desbloqueado():
		_aviso_jefe.visible = true
		return

	var es_repaso := Progreso.esta_liberado(pueblo_id)
	if Ajustes.modo_entrenamiento and pueblo_id != Progreso.PUEBLO_JEFE:
		_mostrar_tabla(pueblo_id, es_repaso)
		return
	batalla_solicitada.emit(pueblo_id, es_repaso)


## Muestra la tabla del pueblo antes de empezar la batalla de entrenamiento.
func _mostrar_tabla(pueblo_id: int, es_repaso: bool) -> void:
	_pueblo_pendiente = pueblo_id
	_repaso_pendiente = es_repaso
	var tabla := Progreso.tabla_del_pueblo(pueblo_id)
	_tabla_titulo.text = "Tabla del %d" % tabla
	for hijo in _tabla_filas.get_children():
		_tabla_filas.remove_child(hijo)
		hijo.queue_free()
	for fila in range(1, 6):
		for multiplicador in [fila, fila + 5]:
			var etiqueta := Label.new()
			etiqueta.text = "%d × %d = %d" % [
				tabla, multiplicador, tabla * multiplicador
			]
			etiqueta.add_theme_font_size_override("font_size", 28)
			etiqueta.add_theme_color_override(
				"font_color", Color(0.95, 0.92, 1, 1)
			)
			_tabla_filas.add_child(etiqueta)
	_tabla.visible = true


func _al_aceptar_tabla() -> void:
	_tabla.visible = false
	batalla_solicitada.emit(_pueblo_pendiente, _repaso_pendiente)


func _cerrar_tabla() -> void:
	_tabla.visible = false


func _al_pulsar_opciones() -> void:
	opciones_solicitada.emit()


## Boton atras de Android: cierra el aviso abierto o pide confirmacion para salir.
func solicitar_atras() -> void:
	if _tabla.visible:
		_cerrar_tabla()
	elif _confirmacion_salir.visible:
		_cerrar_confirmacion()
	elif _aviso_jefe.visible:
		_cerrar_aviso_jefe()
	else:
		_al_pulsar_salir()


## El boton de salir solo abre la confirmacion: cerrar el juego requiere
## pulsar "Si", asi una pulsacion accidental no cierra la partida.
func _al_pulsar_salir() -> void:
	_confirmacion_salir.visible = true


func _cerrar_aviso_jefe() -> void:
	_aviso_jefe.visible = false


func _cerrar_confirmacion() -> void:
	_confirmacion_salir.visible = false


func _al_confirmar_salir() -> void:
	get_tree().quit()

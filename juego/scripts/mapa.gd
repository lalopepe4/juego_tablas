extends Control

## Diez marcadores colocados en el editor sobre las casas del mapa.
## Cada marcador inicia su batalla y desaparece visualmente al liberar el pueblo.

signal batalla_solicitada(pueblo_id: int)
signal opciones_solicitada

const ICONO_SECUAZ := preload("res://assets/personajes/monstruo_secuaz_frente.png")
const ICONO_SOMBRAS := preload("res://assets/personajes/monstruo_de_sombras_frente.png")

## Tamano de diseno del mapa. Los botones se colocaron sobre estas coordenadas.
const TAMANO_LIENZO := Vector2(1280.0, 720.0)

@onready var _lienzo: Control = $Lienzo
@onready var _pueblos: Control = $Lienzo/Pueblos
@onready var _opciones: Button = $Opciones
@onready var _salir: Button = $Salir
@onready var _confirmacion_salir: Control = $Confirmacion
@onready var _confirmar_salir: Button = $Confirmacion/Panel/Margen/Contenido/Botones/Si
@onready var _cancelar_salir: Button = $Confirmacion/Panel/Margen/Contenido/Botones/No


func _ready() -> void:
	_ajustar_lienzo()
	get_viewport().size_changed.connect(_ajustar_lienzo)
	_opciones.pressed.connect(_al_pulsar_opciones)
	_salir.pressed.connect(_al_pulsar_salir)
	_confirmar_salir.pressed.connect(_al_confirmar_salir)
	_cancelar_salir.pressed.connect(_cerrar_confirmacion)
	_confirmacion_salir.visible = false
	for pueblo_id in Progreso.TOTAL_PUEBLOS:
		var boton := _obtener_boton(pueblo_id)
		boton.pressed.connect(_al_pulsar_pueblo.bind(pueblo_id))
		boton.icon = (
			ICONO_SOMBRAS if pueblo_id == Progreso.TOTAL_PUEBLOS - 1 else ICONO_SECUAZ
		)
	_actualizar_botones()


## Escala el lienzo para que quepa entero en la pantalla y lo centra.
## Asi el fondo y los botones conservan siempre la misma posicion relativa,
## aunque la pantalla del movil no sea 16:9.
func _ajustar_lienzo() -> void:
	var vista := get_viewport_rect().size
	var escala := minf(vista.x / TAMANO_LIENZO.x, vista.y / TAMANO_LIENZO.y)
	_lienzo.scale = Vector2(escala, escala)
	_lienzo.position = (vista - TAMANO_LIENZO * escala) * 0.5


func _obtener_boton(pueblo_id: int) -> Button:
	return _pueblos.get_node("Pueblo%d" % (pueblo_id + 1)) as Button


func _actualizar_botones() -> void:
	for pueblo_id in Progreso.TOTAL_PUEBLOS:
		var boton := _obtener_boton(pueblo_id)
		var liberado := Progreso.esta_liberado(pueblo_id)
		boton.disabled = liberado
		if liberado:
			boton.tooltip_text = "Pueblo %d liberado" % (pueblo_id + 1)
		elif pueblo_id == Progreso.TOTAL_PUEBLOS - 1:
			boton.tooltip_text = "Monstruo de Sombras conquista Pueblo %d" % (pueblo_id + 1)
		else:
			boton.tooltip_text = "Secuaz conquista Pueblo %d" % (pueblo_id + 1)

		boton.text = "Pueblo %d\n%s" % [pueblo_id + 1, "liberado" if liberado else "conquistado"]


func _al_pulsar_pueblo(pueblo_id: int) -> void:
	if Progreso.esta_liberado(pueblo_id):
		return
	batalla_solicitada.emit(pueblo_id)


func _al_pulsar_opciones() -> void:
	opciones_solicitada.emit()


## El boton de salir solo abre la confirmacion: cerrar el juego requiere
## pulsar "Si", asi una pulsacion accidental no cierra la partida.
func _al_pulsar_salir() -> void:
	_confirmacion_salir.visible = true


func _cerrar_confirmacion() -> void:
	_confirmacion_salir.visible = false


func _al_confirmar_salir() -> void:
	get_tree().quit()

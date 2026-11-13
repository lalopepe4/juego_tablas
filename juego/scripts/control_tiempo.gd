extends CanvasLayer

## Control de tiempo de uso: avisa cuando se supera el limite configurado.
## Vive como autoload para seguir contando entre el mapa y las batallas.

const RUTA_GUARDADO := "user://configuracion.cfg"
const MIN_MINUTOS := 15
const MAX_MINUTOS := 30
const MINUTOS_POR_DEFECTO := 20

var activo := false
var minutos := MINUTOS_POR_DEFECTO

var _transcurrido := 0.0
var _alarma_visible := false
var _pausa_previa := false

@onready var _alarma: Control = $Alarma
@onready var _mensaje: Label = $Alarma/Panel/Margen/Contenido/Mensaje
@onready var _entendido: Button = $Alarma/Panel/Margen/Contenido/Entendido


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	cargar()
	_alarma.visible = false
	_entendido.pressed.connect(_cerrar_alarma)


func _process(delta: float) -> void:
	if not activo or _alarma_visible:
		return
	_transcurrido += delta
	if _transcurrido >= minutos * 60.0:
		_mostrar_alarma()


## Guarda la configuracion y reinicia la cuenta del tiempo transcurrido.
func configurar(nuevo_activo: bool, nuevos_minutos: int) -> void:
	activo = nuevo_activo
	minutos = clampi(nuevos_minutos, MIN_MINUTOS, MAX_MINUTOS)
	_transcurrido = 0.0
	guardar()


func _mostrar_alarma() -> void:
	_alarma_visible = true
	_mensaje.text = (
		"¡Has estado jugando %d minutos!\nEs hora de descansar un poco." % minutos
	)
	_alarma.visible = true
	_pausa_previa = get_tree().paused
	get_tree().paused = true


func _cerrar_alarma() -> void:
	_alarma.visible = false
	_alarma_visible = false
	_transcurrido = 0.0
	get_tree().paused = _pausa_previa


func guardar() -> void:
	var config := ConfigFile.new()
	config.set_value("tiempo", "activo", activo)
	config.set_value("tiempo", "minutos", minutos)
	config.save(RUTA_GUARDADO)


func cargar() -> void:
	var config := ConfigFile.new()
	if config.load(RUTA_GUARDADO) != OK:
		return
	activo = config.get_value("tiempo", "activo", false)
	minutos = clampi(
		config.get_value("tiempo", "minutos", MINUTOS_POR_DEFECTO),
		MIN_MINUTOS,
		MAX_MINUTOS
	)

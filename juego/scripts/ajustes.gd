extends Node

## Ajustes de la aplicacion: sonido y modo entrenamiento.
##
## Vive como autoload para que el mapa, las batallas y la pantalla de opciones
## lean y escriban el mismo estado. Se guarda en user://ajustes.cfg.

const RUTA_GUARDADO := "user://ajustes.cfg"

var sonido_activo := true
var modo_entrenamiento := false
## Ruta efectiva del archivo. Las pruebas la cambian para no tocar la configuracion.
var ruta_guardado := RUTA_GUARDADO


func _ready() -> void:
	cargar()


func cargar() -> void:
	var config := ConfigFile.new()
	if config.load(ruta_guardado) == OK:
		sonido_activo = _leer_bool(
			config.get_value("sonido", "activo", true), true
		)
		modo_entrenamiento = _leer_bool(
			config.get_value("entrenamiento", "activo", false), false
		)
	_aplicar_sonido()


func guardar() -> void:
	var config := ConfigFile.new()
	config.set_value("sonido", "activo", sonido_activo)
	config.set_value("entrenamiento", "activo", modo_entrenamiento)
	var error := config.save(ruta_guardado)
	if error != OK:
		push_error(
			"No se pudo guardar %s: %s" % [ruta_guardado, error_string(error)]
		)


func establecer_sonido(activo: bool) -> void:
	sonido_activo = activo
	_aplicar_sonido()
	guardar()


func establecer_entrenamiento(activo: bool) -> void:
	modo_entrenamiento = activo
	guardar()


## Silencia todo el juego desde el bus Master.
func _aplicar_sonido() -> void:
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0:
		AudioServer.set_bus_mute(bus, not sonido_activo)


func _leer_bool(valor: Variant, por_defecto: bool) -> bool:
	if valor is bool:
		return valor
	return por_defecto

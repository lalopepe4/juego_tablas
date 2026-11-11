extends Node

## Estado de la partida: que pueblos ha liberado Chispita y que tabla toca.
## Se guarda en user://progreso.cfg para que el avance sobreviva al cierre.

const TOTAL_PUEBLOS := 10
const RUTA_GUARDADO := "user://progreso.cfg"

var pueblos_liberados: Array[int] = []
var tabla_actual := 1


func _ready() -> void:
	cargar()


func esta_liberado(pueblo_id: int) -> bool:
	return pueblos_liberados.has(pueblo_id)


func liberar_pueblo(pueblo_id: int) -> void:
	if not esta_liberado(pueblo_id):
		pueblos_liberados.append(pueblo_id)
		tabla_actual = clampi(pueblo_id + 1, 1, 10)
	guardar()


func reiniciar() -> void:
	pueblos_liberados.clear()
	tabla_actual = 1
	guardar()


func guardar() -> void:
	var config := ConfigFile.new()
	config.set_value("partida", "pueblos_liberados", pueblos_liberados)
	config.set_value("partida", "tabla_actual", tabla_actual)
	config.save(RUTA_GUARDADO)


func cargar() -> void:
	var config := ConfigFile.new()
	if config.load(RUTA_GUARDADO) != OK:
		return
	pueblos_liberados.assign(config.get_value("partida", "pueblos_liberados", []))
	tabla_actual = config.get_value("partida", "tabla_actual", 1)

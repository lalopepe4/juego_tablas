extends PruebaBase

## Pruebas del autoload Ajustes: sonido y modo entrenamiento.

var _ruta := ""
var _mute_original := false


func _init() -> void:
	nombre = "Ajustes"


func ejecutar() -> void:
	_ruta = OS.get_temp_dir().path_join("juego_chispita_ajustes_prueba.cfg")
	var bus := AudioServer.get_bus_index("Master")
	_mute_original = AudioServer.is_bus_mute(bus)
	_borrar()
	_probar_defectos()
	_probar_guardado()
	_probar_datos_invalidos()
	AudioServer.set_bus_mute(bus, _mute_original)
	_borrar()


func _nuevo() -> Node:
	var ajustes: Node = load("res://scripts/ajustes.gd").new()
	ajustes.ruta_guardado = _ruta
	return ajustes


func _borrar() -> void:
	if FileAccess.file_exists(_ruta):
		DirAccess.remove_absolute(_ruta)


func _probar_defectos() -> void:
	var ajustes := _nuevo()
	ajustes.cargar()
	igual("sonido activo por defecto", true, ajustes.sonido_activo)
	igual("entrenamiento apagado por defecto", false, ajustes.modo_entrenamiento)
	comprobar(
		"el bus Master no esta silenciado",
		not AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	)
	ajustes.free()


func _probar_guardado() -> void:
	var ajustes := _nuevo()
	ajustes.establecer_sonido(false)
	ajustes.establecer_entrenamiento(true)
	igual("se apaga el sonido", false, ajustes.sonido_activo)
	igual("se enciende el entrenamiento", true, ajustes.modo_entrenamiento)
	comprobar(
		"apagar el sonido silencia el bus Master",
		AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	)
	ajustes.free()

	var cargado := _nuevo()
	cargado.cargar()
	igual("carga el sonido apagado", false, cargado.sonido_activo)
	igual("carga el entrenamiento encendido", true, cargado.modo_entrenamiento)
	comprobar(
		"cargar aplica el silencio",
		AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	)
	cargado.establecer_sonido(true)
	comprobar(
		"volver a activar el sonido quita el silencio",
		not AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	)
	cargado.free()


func _probar_datos_invalidos() -> void:
	var config := ConfigFile.new()
	config.set_value("sonido", "activo", "si")
	config.set_value("entrenamiento", "activo", 1)
	config.save(_ruta)

	var ajustes := _nuevo()
	ajustes.cargar()
	igual("sonido invalido usa el valor por defecto", true, ajustes.sonido_activo)
	igual(
		"entrenamiento invalido usa el valor por defecto",
		false,
		ajustes.modo_entrenamiento
	)
	ajustes.free()

extends PruebaBase

## Pruebas de Progreso: tablas, desbloqueo, fallos y validacion del guardado.

var _ruta := ""


func _init() -> void:
	nombre = "Progreso"


func ejecutar() -> void:
	_ruta = OS.get_temp_dir().path_join("juego_chispita_progreso_prueba.cfg")
	_borrar()
	_probar_tablas()
	_probar_pueblos()
	_probar_fallos()
	_probar_guardado()
	_probar_version_vieja()
	_probar_datos_invalidos()
	_probar_archivo_inexistente()
	_borrar()


func _nuevo() -> Node:
	var progreso: Node = load("res://scripts/progreso.gd").new()
	progreso.ruta_guardado = _ruta
	return progreso


func _borrar() -> void:
	if FileAccess.file_exists(_ruta):
		DirAccess.remove_absolute(_ruta)


func _probar_tablas() -> void:
	var progreso := _nuevo()
	igual("tabla del pueblo 0", 2, progreso.tabla_del_pueblo(0))
	igual("tabla del pueblo 8", 10, progreso.tabla_del_pueblo(8))
	igual("nueve secuaces", 9, progreso.TOTAL_SECUACES)
	igual("el jefe es el pueblo 9", 9, progreso.PUEBLO_JEFE)
	igual("tablas de los secuaces", [2, 3, 4, 5, 6, 7, 8, 9, 10], progreso.tablas_secuaces())
	progreso.free()


func _probar_pueblos() -> void:
	var progreso := _nuevo()
	comprobar("el jefe empieza bloqueado", not progreso.jefe_desbloqueado())

	for pueblo in 8:
		progreso.liberar_pueblo(pueblo)
	comprobar("el jefe sigue bloqueado con ocho pueblos", not progreso.jefe_desbloqueado())

	progreso.liberar_pueblo(8)
	comprobar("el jefe se desbloquea con nueve pueblos", progreso.jefe_desbloqueado())
	progreso.liberar_pueblo(8)
	igual("liberar dos veces no duplica", 9, progreso.pueblos_liberados.size())
	comprobar("esta_liberado", progreso.esta_liberado(0))
	comprobar("el jefe no esta liberado", not progreso.esta_liberado(9))
	progreso.free()


func _probar_fallos() -> void:
	var progreso := _nuevo()
	var pregunta := Pregunta.new(7, 8)
	igual("sin fallos", 0, progreso.fallos_de(pregunta))

	progreso.registrar_fallo(pregunta)
	progreso.registrar_fallo(pregunta)
	igual("acumula fallos", 2, progreso.fallos_de(pregunta))
	igual("otra pregunta es independiente", 0, progreso.fallos_de(Pregunta.new(7, 9)))
	comprobar("guarda la clave de la pregunta", progreso.fallos.has("7 x 8"))
	progreso.free()


func _probar_guardado() -> void:
	var progreso := _nuevo()
	progreso.liberar_pueblo(0)
	progreso.liberar_pueblo(3)
	progreso.registrar_fallo(Pregunta.new(7, 8))
	progreso.registrar_fallo(Pregunta.new(7, 8))
	progreso.guardar()
	progreso.free()

	var cargado := _nuevo()
	cargado.cargar()
	igual("carga los pueblos", [0, 3], cargado.pueblos_liberados)
	igual("carga los fallos", 2, cargado.fallos_de(Pregunta.new(7, 8)))

	cargado.reiniciar()
	igual("reiniciar limpia los pueblos", 0, cargado.pueblos_liberados.size())
	igual("reiniciar limpia los fallos", 0, cargado.fallos.size())
	cargado.free()

	var vacio := _nuevo()
	vacio.cargar()
	igual("el reinicio se guarda", 0, vacio.pueblos_liberados.size())
	vacio.free()


func _probar_version_vieja() -> void:
	var config := ConfigFile.new()
	config.set_value("partida", "version", 0)
	config.set_value("partida", "pueblos_liberados", [1, 2])
	config.set_value("partida", "fallos", {"7 x 8": 4})
	config.save(_ruta)

	var progreso := _nuevo()
	progreso.cargar()
	igual("version vieja: pueblos vacios", 0, progreso.pueblos_liberados.size())
	igual("version vieja: fallos vacios", 0, progreso.fallos.size())
	progreso.free()


func _probar_datos_invalidos() -> void:
	var config := ConfigFile.new()
	config.set_value("partida", "version", 1)
	config.set_value(
		"partida", "pueblos_liberados", ["dos", 3, 3, 99, -1, 4.0, 7.5]
	)
	config.set_value(
		"partida",
		"fallos",
		{"7 x 8": 3, "mal": "muchos", 4: 2, "negativo": -1, "decimal": 2.5}
	)
	config.save(_ruta)

	var progreso := _nuevo()
	progreso.cargar()
	igual("pueblos validos y sin duplicados", [3, 4], progreso.pueblos_liberados)
	igual(
		"fallos validos y no negativos",
		{"7 x 8": 3, "negativo": 0},
		progreso.fallos
	)
	progreso.free()

	config = ConfigFile.new()
	config.set_value("partida", "version", 1)
	config.set_value("partida", "pueblos_liberados", "3,4")
	config.set_value("partida", "fallos", [1, 2])
	config.save(_ruta)

	var tipos_malos := _nuevo()
	tipos_malos.cargar()
	igual("pueblos con tipo incorrecto", 0, tipos_malos.pueblos_liberados.size())
	igual("fallos con tipo incorrecto", 0, tipos_malos.fallos.size())
	tipos_malos.free()


func _probar_archivo_inexistente() -> void:
	_borrar()
	var progreso := _nuevo()
	progreso.cargar()
	igual("sin archivo: pueblos vacios", 0, progreso.pueblos_liberados.size())
	igual("sin archivo: fallos vacios", 0, progreso.fallos.size())
	progreso.free()

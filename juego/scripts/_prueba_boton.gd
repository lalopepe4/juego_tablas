extends SceneTree

## Prueba temporal: estado del boton del jefe en el mapa.

func _initialize() -> void:
	_capturar.call_deferred()


func _capturar() -> void:
	var progreso: Node = root.get_node("Progreso")
	progreso.pueblos_liberados.clear()
	progreso.fallos.clear()
	var mapa: Node = load("res://scenes/mapa.tscn").instantiate()
	root.add_child(mapa)
	await process_frame
	for nombre in ["Pueblo9", "Pueblo10"]:
		var boton: Button = mapa.get_node("Lienzo/Pueblos/" + nombre)
		print(
			nombre,
			" disabled=",
			boton.disabled,
			" icon=",
			boton.icon,
			" modulate=",
			boton.modulate,
			" size=",
			boton.size,
			" pos=",
			boton.position,
			" text=",
			boton.text
		)
		print(
			"  icon_alignment=",
			boton.icon_alignment,
			" vertical=",
			boton.vertical_icon_alignment,
			" expand=",
			boton.expand_icon,
			" icon_disabled=",
			boton.get_theme_color("icon_disabled_color")
		)
	quit()

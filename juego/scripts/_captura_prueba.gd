extends SceneTree

var frames := 0


func _initialize() -> void:
	var escena: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(escena)


func _process(_delta: float) -> bool:
	frames += 1
	if frames == 40:
		var img := root.get_texture().get_image()
		print("IMG ", img.get_size(), " pixel=", img.get_pixel(640, 360))
		img.save_png("/tmp/captura.png")
		return true
	return false

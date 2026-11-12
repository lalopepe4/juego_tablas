class_name GeneradorPreguntas
extends RefCounted

## Genera la suma de tres cifras que abre el botiquin.


static func pregunta_botiquin(rng: RandomNumberGenerator) -> Dictionary:
	var a := rng.randi_range(100, 499)
	var b := rng.randi_range(100, 499)
	return {
		"texto": "%d + %d" % [a, b],
		"correcta": a + b,
	}

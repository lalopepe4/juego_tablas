class_name Poses
extends RefCounted

## Texturas de las poses de cada personaje y de los efectos de ataque.
##
## Las claves de `TEXTURAS` son el personaje ("heroe", "sombras" o "secuaz") y
## los estados coinciden con los que usa la batalla: base, asustado,
## concentrado, satisfecho, atacando, sorprendido, herido, celebrando y
## derrotado.

const TEXTURAS := {
	"heroe": {
		"base": preload("res://assets/personajes/heroe_chispita.png"),
		"asustado": preload("res://assets/personajes/heroe_chispita_asustado.png"),
		"concentrado": preload("res://assets/personajes/heroe_chispita_concentrado.png"),
		"satisfecho": preload("res://assets/personajes/heroe_chispita_satisfecho.png"),
		"atacando": preload("res://assets/personajes/heroe_chispita_atacando.png"),
		"sorprendido": preload("res://assets/personajes/heroe_chispita_sorprendido.png"),
		"herido": preload("res://assets/personajes/heroe_chispita_herido.png"),
		"celebrando": preload("res://assets/personajes/heroe_chispita_celebrando.png"),
		"derrotado": preload("res://assets/personajes/heroe_chispita_derrotado.png"),
	},
	"sombras": {
		"base": preload("res://assets/personajes/monstruo_de_sombras.png"),
		"asustado": preload("res://assets/personajes/monstruo_de_sombras_asustado.png"),
		"concentrado": preload("res://assets/personajes/monstruo_de_sombras_concentrado.png"),
		"satisfecho": preload("res://assets/personajes/monstruo_de_sombras_satisfecho.png"),
		"atacando": preload("res://assets/personajes/monstruo_de_sombras_atacando.png"),
		"sorprendido": preload(
			"res://assets/personajes/monstruo_de_sombras_sorprendido.png"
		),
		"herido": preload("res://assets/personajes/monstruo_de_sombras_herido.png"),
		"celebrando": preload("res://assets/personajes/monstruo_de_sombras_celebrando.png"),
		"derrotado": preload("res://assets/personajes/monstruo_de_sombras_derrotado.png"),
	},
	"secuaz": {
		"base": preload("res://assets/personajes/monstruo_secuaz.png"),
		"asustado": preload("res://assets/personajes/monstruo_secuaz_asustado.png"),
		"concentrado": preload("res://assets/personajes/monstruo_secuaz_concentrado.png"),
		"satisfecho": preload("res://assets/personajes/monstruo_secuaz_satisfecho.png"),
		"atacando": preload("res://assets/personajes/monstruo_secuaz_atacando.png"),
		"sorprendido": preload("res://assets/personajes/monstruo_secuaz_sorprendido.png"),
		"herido": preload("res://assets/personajes/monstruo_secuaz_herido.png"),
		"celebrando": preload("res://assets/personajes/monstruo_secuaz_celebrando.png"),
		"derrotado": preload("res://assets/personajes/monstruo_secuaz_derrotado.png"),
	},
}

const ATAQUE_HEROE := preload("res://assets/objetos/ataque_chispita.png")
const ATAQUE_ENEMIGO := preload("res://assets/objetos/ataque_sombra.png")
const IMPACTO := preload("res://assets/objetos/impacto.png")


## Clave de `TEXTURAS` para el enemigo segun si la batalla es contra el jefe.
static func clave_enemigo(es_jefe: bool) -> String:
	return "sombras" if es_jefe else "secuaz"


## Textura del estado pedido; si no existe se usa la pose base del personaje.
static func textura(clave: String, estado: String) -> Texture2D:
	var poses: Dictionary = TEXTURAS[clave]
	return poses.get(estado, poses["base"])

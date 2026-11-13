class_name Sonidos
extends Node

## Reproductores de audio de la batalla.
##
## Crea un reproductor por canal (respuesta, ataque y final) y elige el sonido
## segun el bando y el tipo de enemigo, para que la escena solo pida lo que
## quiere oir.

const ATAQUE_HEROE := preload("res://assets/sonido/AtaqueHeroe.mp3")
const ATAQUE_SOMBRAS := preload("res://assets/sonido/AtaqueMonstruo.mp3")
const ATAQUE_SECUAZ := preload("res://assets/sonido/AtaqueSecuaz.mp3")
const RESPUESTA_CORRECTA := preload("res://assets/sonido/RespuestaCorrecta.wav")
const RESPUESTA_INCORRECTA := preload("res://assets/sonido/RespuestaIncorrecta.mp3")
const VICTORIA_SECUACES := preload("res://assets/sonido/GanasteBatalla.mp3")
const VICTORIA_FINAL := preload("res://assets/sonido/GanasteUltimaBatalla.mp3")
const DERROTA := preload("res://assets/sonido/PerdisteBatalla.mp3")

var _respuesta: AudioStreamPlayer
var _ataque: AudioStreamPlayer
var _final: AudioStreamPlayer


func _ready() -> void:
	_respuesta = _crear_reproductor("SonidoRespuesta")
	_ataque = _crear_reproductor("SonidoAtaque")
	_final = _crear_reproductor("SonidoFinal")


func respuesta(acierto: bool) -> void:
	_reproducir(_respuesta, RESPUESTA_CORRECTA if acierto else RESPUESTA_INCORRECTA)


func ataque(es_heroe: bool, es_jefe: bool) -> void:
	var sonido: AudioStream = ATAQUE_HEROE
	if not es_heroe:
		sonido = ATAQUE_SOMBRAS if es_jefe else ATAQUE_SECUAZ
	_reproducir(_ataque, sonido)


func victoria(es_jefe: bool) -> void:
	_reproducir(_final, VICTORIA_FINAL if es_jefe else VICTORIA_SECUACES)


func derrota() -> void:
	_reproducir(_final, DERROTA)


func _crear_reproductor(nombre: String) -> AudioStreamPlayer:
	var reproductor := AudioStreamPlayer.new()
	reproductor.name = nombre
	add_child(reproductor)
	return reproductor


func _reproducir(reproductor: AudioStreamPlayer, sonido: AudioStream) -> void:
	reproductor.stream = sonido
	reproductor.play()

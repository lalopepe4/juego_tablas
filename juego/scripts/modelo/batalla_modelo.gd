class_name Batalla
extends RefCounted

## Logica de una batalla: preguntas, ataques y ganador.
##
## El modelo no conoce animaciones ni tiempos. Solo avisa con señales de lo que
## va pasando; la escena escucha esas señales, reproduce la animacion y llama a
## aplicar_dano() y avanzar() cuando termina, para que todo ocurra en orden.

signal ganador_changed(ganador: Personaje)
signal pregunta_changed(pregunta: Pregunta)
signal respuesta_changed(acierto: bool, atacante: Personaje, defensor: Personaje)

var heroe: Personaje
var enemigo: Personaje
var pueblo: Pueblo

var _ganador: Personaje = null
var ganador: Personaje:
	get:
		return _ganador
	set(valor):
		if _ganador == valor:
			return
		_ganador = valor
		ganador_changed.emit(valor)

var _pregunta: Pregunta = null
var pregunta: Pregunta:
	get:
		return _pregunta
	set(valor):
		if _pregunta == valor:
			return
		_pregunta = valor
		pregunta_changed.emit(valor)

var respuesta := ""
var ultimo_acierto := false

var _atacante_pendiente: Personaje = null
var _defensor_pendiente: Personaje = null

var _rng := RandomNumberGenerator.new()


func _init(p_heroe: Personaje, p_enemigo: Personaje, p_pueblo: Pueblo) -> void:
	heroe = p_heroe
	enemigo = p_enemigo
	pueblo = p_pueblo
	_rng.randomize()
	ganador_changed.connect(_al_cambiar_ganador)


func iniciar() -> void:
	heroe.vida = Personaje.VIDA_MAXIMA
	enemigo.vida = Personaje.VIDA_MAXIMA
	heroe.ataque = 10
	enemigo.ataque = 10
	for p in pueblo.preguntas:
		p.respondida = false
		p.intentos = 0
	pregunta = GeneradorOpciones.seleccionar_pregunta(pueblo, _rng)


func responder(opcion: String) -> void:
	if pregunta == null or _atacante_pendiente != null:
		return

	respuesta = opcion
	ultimo_acierto = pregunta.respuesta_literal == opcion
	if ultimo_acierto:
		pregunta.respondida = true
		_atacante_pendiente = heroe
		_defensor_pendiente = enemigo
		heroe.mensaje = "La respuesta es %s." % opcion
	else:
		_atacante_pendiente = enemigo
		_defensor_pendiente = heroe
		enemigo.mensaje = (
			"¡Ja! Has fallado. La respuesta era %s." % pregunta.respuesta_literal
		)

	respuesta_changed.emit(ultimo_acierto, _atacante_pendiente, _defensor_pendiente)


## Aplica el ataque pendiente. La escena la llama cuando termina la animacion
## del ataque y antes de la animacion del daño.
func aplicar_dano() -> void:
	if _atacante_pendiente == null or _defensor_pendiente == null:
		return
	_atacante_pendiente.atacar(_defensor_pendiente)
	_atacante_pendiente = null
	_defensor_pendiente = null


## Elige la siguiente pregunta o declara el ganador. La escena la llama cuando
## terminan las animaciones de ataque y daño.
func avanzar() -> void:
	aplicar_dano()

	if heroe.vida <= 0:
		ganador = enemigo
		return
	if enemigo.vida <= 0:
		ganador = heroe
		return

	var siguiente := GeneradorOpciones.seleccionar_pregunta(pueblo, _rng)
	if siguiente == null:
		ganador = heroe
		return
	pregunta = siguiente


func _al_cambiar_ganador(nuevo_ganador: Personaje) -> void:
	if nuevo_ganador == null:
		return
	nuevo_ganador.mensaje = "¡He ganado la batalla!"

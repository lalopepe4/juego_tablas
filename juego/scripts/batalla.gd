extends Control

## Modo batalla: Chispita responde la tabla del pueblo para derrotar al secuaz.
##
## La logica vive en las clases del modelo (Pregunta, Pueblo, Personaje,
## Batalla y GeneradorOpciones). Este script conecta esa logica con la interfaz
## y usa cada signal del modelo como punto de partida de una animacion. Las
## animaciones, las poses, los sonidos y el botiquin viven en modulos aparte
## (`scripts/batalla/`).

signal batalla_terminada(victoria: bool, pueblo_id: int)
signal volver_solicitada

const CURACION_BOTIQUIN := 30
const PAUSA_TRAS_DANO := 0.5
const PAUSA_FINAL := 0.4

var pueblo_id := 0

var _batalla: Batalla
var _heroe: Personaje
var _enemigo: Personaje
var _pueblo: Pueblo
var _rng := RandomNumberGenerator.new()
var _es_jefe := false
var _botiquin_disponible := true
var _pregunta_suspendida: Pregunta
var _volver_antes := false

@onready var _volver: Button = $Volver
@onready var _confirmacion: Control = $Confirmacion
@onready var _confirmar_salida: Button = (
	$Confirmacion/Panel/Margen/Contenido/Botones/Si
)
@onready var _cancelar_salida: Button = (
	$Confirmacion/Panel/Margen/Contenido/Botones/No
)
@onready var _sprite_heroe: TextureRect = $Lienzo/HeroeSprite
@onready var _sprite_monstruo: TextureRect = $Lienzo/MonstruoSprite
@onready var _barra_heroe: Control = $Lienzo/Heroe
@onready var _barra_monstruo: Control = $Lienzo/Monstruo
@onready var _pregunta: Label = $Lienzo/Nube/Pregunta
@onready var _opciones: Array[Button] = [
	$Lienzo/Opciones/Opcion1, $Lienzo/Opciones/Opcion2, $Lienzo/Opciones/Opcion3
]
@onready var _mensaje: Label = $Lienzo/Mensaje
@onready var _botiquin: Botiquin = $Lienzo/Botiquin
@onready var _animador: AnimadorBatalla = $Lienzo/Animador
@onready var _sonidos: Sonidos = $Sonidos


func _ready() -> void:
	_es_jefe = pueblo_id == Progreso.PUEBLO_JEFE
	# Volver se habilita cuando hay una pregunta esperando respuesta.
	_volver.disabled = true
	_volver.pressed.connect(_al_pulsar_volver)
	_confirmacion.visible = false
	_confirmar_salida.pressed.connect(_al_confirmar_salida)
	_cancelar_salida.pressed.connect(_cerrar_confirmacion)
	_rng.randomize()
	if _es_jefe:
		_pueblo = Pueblo.jefe(
			SelectorJefe.seleccionar(Progreso.tablas_secuaces(), Progreso.fallos, _rng)
		)
	else:
		_pueblo = Pueblo.de_tabla(Progreso.tabla_del_pueblo(pueblo_id))
	_heroe = Personaje.new("Chispita")
	_enemigo = Personaje.new("Monstruo de Sombras" if _es_jefe else "Secuaz")
	_batalla = Batalla.new(_heroe, _enemigo, _pueblo)

	_poner_pose("heroe", "base")
	_poner_pose("enemigo", "base")

	_batalla.pregunta_changed.connect(_al_cambiar_pregunta)
	_batalla.respuesta_changed.connect(_al_cambiar_respuesta)
	_batalla.ganador_changed.connect(_al_cambiar_ganador)
	_heroe.vida_changed.connect(_actualizar_barras)
	_enemigo.vida_changed.connect(_actualizar_barras)

	for indice in _opciones.size():
		_opciones[indice].pressed.connect(_al_responder.bind(indice))
	_botiquin.solicitado.connect(_al_abrir_botiquin)
	_botiquin.cancelado.connect(_al_cancelar_botiquin)
	_botiquin.resuelto.connect(_al_resolver_botiquin)

	_preparar_escena()
	_actualizar_barras()

	# El escenario empieza vacio: primero entran los personajes, luego el
	# botiquin y solo entonces arranca la logica de la batalla.
	await _animador.introducir_personajes()
	await _botiquin.introducir()
	_batalla.iniciar()
	if _batalla.pregunta == null:
		# Sin preguntas no hay forma de terminar la batalla: deja salir.
		_volver.disabled = false


func _preparar_escena() -> void:
	_bloquear_opciones()
	_habilitar_botiquin(false)
	_mensaje.text = ""


func _al_cambiar_pregunta(pregunta: Pregunta) -> void:
	if pregunta == null:
		_bloquear_opciones()
		_habilitar_botiquin(false)
		return

	_poner_pose("heroe", "concentrado")
	_poner_pose("enemigo", "concentrado")
	_bloquear_opciones()
	_habilitar_botiquin(false)
	_pregunta.text = pregunta.pregunta_literal
	for indice in _opciones.size():
		_opciones[indice].text = pregunta.opciones[indice]
	_mensaje.text = ""

	await _animador.entrar_nube()

	if _botiquin.abierto or _batalla.ganador != null:
		return
	for indice in _opciones.size():
		_opciones[indice].disabled = false
	_habilitar_botiquin(_botiquin_disponible)
	_volver.disabled = false


func _al_responder(indice: int) -> void:
	if _batalla.pregunta == null or _batalla.ganador != null:
		return

	_volver.disabled = true
	_bloquear_opciones()
	_habilitar_botiquin(false)
	_batalla.responder(_opciones[indice].text)


func _al_cambiar_respuesta(
	acierto: bool, atacante: Personaje, defensor: Personaje
) -> void:
	if _batalla.pregunta == null:
		return

	_sonidos.respuesta(acierto)
	if acierto:
		_mensaje.text = "¡Correcto! La respuesta es %s." % _batalla.pregunta.respuesta_literal
	else:
		_mensaje.text = "Fallaste. La respuesta era %s." % _batalla.pregunta.respuesta_literal
		# El jefe elige sus preguntas con este historial; su propia batalla no cuenta.
		if not _es_jefe:
			Progreso.registrar_fallo(_batalla.pregunta)

	var atacante_lado := "heroe" if atacante == _heroe else "enemigo"
	var defensor_lado := "heroe" if defensor == _heroe else "enemigo"
	_poner_pose(atacante_lado, "satisfecho")
	_poner_pose(defensor_lado, "sorprendido")
	await _animador.ocultar_opciones()
	await _animador.salir_nube()
	await _animador.esperar(0.2)
	_poner_pose(atacante_lado, "atacando")
	_sonidos.ataque(atacante == _heroe, _es_jefe)
	await _animador.animar_ataque(atacante == _heroe)
	_batalla.aplicar_dano()
	_poner_pose(defensor_lado, "herido")
	await _animador.animar_impacto(defensor == _heroe)
	await _animador.animar_dano(defensor == _heroe)
	await _animador.esperar(PAUSA_TRAS_DANO)
	_poner_pose_idle()
	_batalla.avanzar()


func _al_cambiar_ganador(ganador: Personaje) -> void:
	if ganador == null:
		return

	_volver.disabled = true
	_confirmacion.visible = false
	_bloquear_opciones()
	_habilitar_botiquin(false)
	_botiquin.ocultar_controles()

	var victoria := ganador == _heroe
	_poner_pose("enemigo" if victoria else "heroe", "derrotado")
	if victoria:
		_sonidos.victoria(_es_jefe)
	else:
		_sonidos.derrota()
	_mensaje.text = (
		"¡Pueblo liberado!" if victoria else "Chispita se ha quedado sin fuerzas..."
	)

	_animador.ocultar_barras()

	await _animador.despedir_perdedor(victoria)
	_poner_pose("heroe" if victoria else "enemigo", "celebrando")
	await _animador.celebrar_ganador(victoria)
	await _animador.esperar(PAUSA_FINAL)
	batalla_terminada.emit(victoria, pueblo_id)


func _actualizar_barras() -> void:
	_barra_heroe.set_vida(_heroe.vida, Personaje.VIDA_MAXIMA)
	_barra_monstruo.set_vida(_enemigo.vida, Personaje.VIDA_MAXIMA)


func _poner_pose(lado: String, estado: String) -> void:
	if lado == "heroe":
		_sprite_heroe.texture = Poses.textura("heroe", estado)
	else:
		_sprite_monstruo.texture = Poses.textura(Poses.clave_enemigo(_es_jefe), estado)


func _poner_pose_idle() -> void:
	_poner_pose("heroe", "asustado" if _heroe.vida <= 30 else "base")
	_poner_pose("enemigo", "herido" if _enemigo.vida <= 30 else "base")


func _al_abrir_botiquin() -> void:
	if not _botiquin_disponible or _batalla.ganador != null:
		return

	_volver.disabled = true
	_habilitar_botiquin(false)
	_bloquear_opciones()
	_pregunta_suspendida = _batalla.pregunta
	if _pregunta_suspendida != null:
		_batalla.pregunta = null

	await _animador.salir_nube()
	await _animador.ocultar_opciones()
	await _botiquin.abrir(_rng)


func _al_cancelar_botiquin() -> void:
	await _cerrar_botiquin(false, false)


func _al_resolver_botiquin(acierto: bool) -> void:
	await _cerrar_botiquin(acierto, true)


func _cerrar_botiquin(acierto: bool, evaluar: bool) -> void:
	await _botiquin.cerrar()

	if evaluar and acierto:
		_botiquin_disponible = false
		_poner_pose("heroe", "satisfecho")
		_heroe.curar(CURACION_BOTIQUIN)
		_mensaje.text = "¡Botiquín usado! Chispita recupera %d de vida." % CURACION_BOTIQUIN
		await _animador.esperar(0.9)
	elif evaluar:
		_mensaje.text = "La suma no es correcta. Puedes volver a intentarlo."
	_poner_pose("heroe", "concentrado")

	if _batalla.ganador == null and _pregunta_suspendida != null:
		var pregunta_guardada := _pregunta_suspendida
		_pregunta_suspendida = null
		_batalla.pregunta = pregunta_guardada
	else:
		_habilitar_botiquin(_botiquin_disponible)
		if _batalla.ganador == null:
			_volver.disabled = false


func _bloquear_opciones() -> void:
	for boton in _opciones:
		boton.disabled = true


func _habilitar_botiquin(habilitado: bool) -> void:
	_botiquin.habilitar(habilitado)


func _al_pulsar_volver() -> void:
	_mostrar_confirmacion()


## Boton atras de Android: cierra el aviso o pide confirmacion para salir.
func solicitar_atras() -> void:
	if _confirmacion.visible:
		_cerrar_confirmacion()
	else:
		_mostrar_confirmacion()


func _mostrar_confirmacion() -> void:
	if _confirmacion.visible:
		return
	_volver_antes = _volver.disabled
	_volver.disabled = true
	_confirmacion.visible = true


func _cerrar_confirmacion() -> void:
	_confirmacion.visible = false
	_volver.disabled = _volver_antes


func _al_confirmar_salida() -> void:
	_confirmacion.visible = false
	volver_solicitada.emit()

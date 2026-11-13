extends PruebaBase

## Pruebas de la logica de Batalla y de Personaje.

func _init() -> void:
	nombre = "Batalla"


func ejecutar() -> void:
	_probar_inicio()
	_probar_acierto()
	_probar_fallo()
	_probar_respuestas_ignoradas()
	_probar_ganador_por_vida()
	_probar_ganador_sin_preguntas()
	_probar_progreso()
	_probar_personaje()


func _nueva() -> Batalla:
	return Batalla.new(
		Personaje.new("Chispita"), Personaje.new("Secuaz"), Pueblo.de_tabla(3)
	)


func _probar_inicio() -> void:
	var batalla := _nueva()
	var avisos := [0]
	batalla.pregunta_changed.connect(func(_p: Pregunta) -> void: avisos[0] += 1)

	batalla.iniciar()
	igual("inicio: vida del heroe", Personaje.VIDA_MAXIMA, batalla.heroe.vida)
	igual("inicio: vida del enemigo", Personaje.VIDA_MAXIMA, batalla.enemigo.vida)
	comprobar("inicio: hay pregunta", batalla.pregunta != null)
	comprobar("inicio: la pregunta no esta respondida", not batalla.pregunta.respondida)
	igual("inicio: avisa de la pregunta", 1, avisos[0])
	comprobar(
		"inicio: ninguna pregunta queda respondida",
		not _alguna_respondida(batalla.pueblo)
	)
	comprobar("inicio: sin ganador", batalla.ganador == null)


func _probar_acierto() -> void:
	var batalla := _nueva()
	batalla.iniciar()
	var registro := _escuchar_respuesta(batalla)
	var pregunta := batalla.pregunta

	batalla.responder(pregunta.respuesta_literal)
	igual("acierto: se marca como acierto", true, registro.get("acierto"))
	comprobar("acierto: ataca el heroe", registro.get("atacante") == batalla.heroe)
	comprobar("acierto: defiende el enemigo", registro.get("defensor") == batalla.enemigo)
	comprobar("acierto: la pregunta queda respondida", pregunta.respondida)
	igual(
		"acierto: la vida no cambia hasta aplicar el dano",
		Personaje.VIDA_MAXIMA,
		batalla.enemigo.vida
	)

	batalla.aplicar_dano()
	igual(
		"acierto: el enemigo pierde un ataque",
		Personaje.VIDA_MAXIMA - 10,
		batalla.enemigo.vida
	)
	igual("acierto: el heroe sigue intacto", Personaje.VIDA_MAXIMA, batalla.heroe.vida)

	var avisos := [0]
	batalla.pregunta_changed.connect(func(_p: Pregunta) -> void: avisos[0] += 1)
	batalla.avanzar()
	igual("acierto: avanzar avisa de la siguiente pregunta", 1, avisos[0])
	comprobar("acierto: la siguiente pregunta es distinta", batalla.pregunta != pregunta)
	comprobar("acierto: sin ganador todavia", batalla.ganador == null)


func _probar_fallo() -> void:
	var batalla := _nueva()
	batalla.iniciar()
	var registro := _escuchar_respuesta(batalla)
	var pregunta := batalla.pregunta

	batalla.responder("999999")
	igual("fallo: se marca como fallo", false, registro.get("acierto"))
	comprobar("fallo: ataca el enemigo", registro.get("atacante") == batalla.enemigo)
	comprobar("fallo: defiende el heroe", registro.get("defensor") == batalla.heroe)
	comprobar("fallo: la pregunta no queda respondida", not pregunta.respondida)
	igual("fallo: ultimo_acierto es falso", false, batalla.ultimo_acierto)

	batalla.aplicar_dano()
	igual("fallo: el heroe pierde un ataque", Personaje.VIDA_MAXIMA - 10, batalla.heroe.vida)
	igual("fallo: el enemigo sigue intacto", Personaje.VIDA_MAXIMA, batalla.enemigo.vida)


func _probar_respuestas_ignoradas() -> void:
	var batalla := _nueva()
	batalla.iniciar()
	var avisos := [0]
	batalla.respuesta_changed.connect(
		func(_a: bool, _at: Personaje, _de: Personaje) -> void: avisos[0] += 1
	)

	batalla.responder(batalla.pregunta.respuesta_literal)
	batalla.responder("otra")
	igual("doble respuesta: solo avisa una vez", 1, avisos[0])
	comprobar("doble respuesta: conserva el primer acierto", batalla.ultimo_acierto)
	batalla.aplicar_dano()
	igual(
		"doble respuesta: solo aplica un ataque",
		Personaje.VIDA_MAXIMA - 10,
		batalla.enemigo.vida
	)

	var sin_pregunta := _nueva()
	sin_pregunta.pregunta = null
	var avisos_sin_pregunta := [0]
	sin_pregunta.respuesta_changed.connect(
		func(_a: bool, _at: Personaje, _de: Personaje) -> void: avisos_sin_pregunta[0] += 1
	)
	sin_pregunta.responder("7")
	igual("sin pregunta: no avisa", 0, avisos_sin_pregunta[0])
	sin_pregunta.aplicar_dano()
	igual(
		"sin dano pendiente: no cambia la vida",
		Personaje.VIDA_MAXIMA,
		sin_pregunta.heroe.vida
	)


func _probar_ganador_por_vida() -> void:
	var victoria := _nueva()
	victoria.iniciar()
	var ganadores: Array[Personaje] = []
	victoria.ganador_changed.connect(func(g: Personaje) -> void: ganadores.append(g))

	victoria.enemigo.vida = 10
	victoria.responder(victoria.pregunta.respuesta_literal)
	victoria.aplicar_dano()
	victoria.avanzar()
	comprobar("victoria: gana el heroe", victoria.ganador == victoria.heroe)
	igual("victoria: la vida del enemigo llega a cero", 0, victoria.enemigo.vida)
	igual("victoria: avisa una vez", 1, ganadores.size())

	victoria.avanzar()
	igual("victoria: no repite el aviso", 1, ganadores.size())

	var derrota := _nueva()
	derrota.iniciar()
	derrota.heroe.vida = 10
	derrota.responder("999999")
	derrota.aplicar_dano()
	derrota.avanzar()
	comprobar("derrota: gana el enemigo", derrota.ganador == derrota.enemigo)
	igual("derrota: la vida del heroe llega a cero", 0, derrota.heroe.vida)


func _probar_ganador_sin_preguntas() -> void:
	var batalla := _nueva()
	batalla.iniciar()
	for pregunta in batalla.pueblo.preguntas:
		pregunta.respondida = true

	batalla.responder(batalla.pregunta.respuesta_literal)
	batalla.aplicar_dano()
	batalla.avanzar()
	comprobar("sin preguntas: gana el heroe", batalla.ganador == batalla.heroe)


func _probar_progreso() -> void:
	var batalla := _nueva()
	batalla.iniciar()
	igual("progreso: total de preguntas", 10, batalla.total_preguntas())
	igual("progreso: cero respondidas al empezar", 0, batalla.preguntas_respondidas())

	batalla.responder(batalla.pregunta.respuesta_literal)
	batalla.aplicar_dano()
	batalla.avanzar()
	igual("progreso: un acierto suma", 1, batalla.preguntas_respondidas())

	batalla.responder("999999")
	batalla.aplicar_dano()
	batalla.avanzar()
	igual("progreso: un fallo no suma", 1, batalla.preguntas_respondidas())


func _probar_personaje() -> void:
	var heroe := Personaje.new("Chispita")
	var enemigo := Personaje.new("Secuaz")

	var avisos := [0]
	enemigo.vida_changed.connect(func() -> void: avisos[0] += 1)

	heroe.atacar(enemigo)
	igual("personaje: ataque", Personaje.VIDA_MAXIMA - 10, enemigo.vida)
	igual("personaje: avisa del cambio de vida", 1, avisos[0])

	enemigo.vida = -50
	igual("personaje: la vida no baja de cero", 0, enemigo.vida)

	enemigo.curar(30)
	igual("personaje: cura", 30, enemigo.vida)
	enemigo.curar(1000)
	igual(
		"personaje: la curacion no pasa del maximo",
		Personaje.VIDA_MAXIMA,
		enemigo.vida
	)


func _escuchar_respuesta(batalla: Batalla) -> Dictionary:
	var registro := {}
	batalla.respuesta_changed.connect(
		func(acierto: bool, atacante: Personaje, defensor: Personaje) -> void:
			registro["acierto"] = acierto
			registro["atacante"] = atacante
			registro["defensor"] = defensor
	)
	return registro


func _alguna_respondida(pueblo: Pueblo) -> bool:
	for pregunta in pueblo.preguntas:
		if pregunta.respondida:
			return true
	return false

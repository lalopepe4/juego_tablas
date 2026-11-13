extends Node

## Estado de la partida: pueblos liberados y fallos acumulados por multiplicacion.
## Se guarda en user://progreso.cfg para que el avance sobreviva al cierre.

const TOTAL_PUEBLOS := 10
const PUEBLO_JEFE := TOTAL_PUEBLOS - 1
const TOTAL_SECUACES := PUEBLO_JEFE
const PRIMERA_TABLA := 2
const ULTIMA_TABLA := 10
## Subirla cuando cambie el significado de los datos guardados: al cargar una
## partida de una version menor se borra, igual que con "Limpiar Progreso".
const VERSION_PARTIDA := 1
const RUTA_GUARDADO := "user://progreso.cfg"

var pueblos_liberados: Array[int] = []
## Fallos por multiplicacion. La clave es Pregunta.clave ("tabla x multiplicador").
var fallos: Dictionary = {}
## Ruta efectiva del archivo. Las pruebas la cambian para no tocar la partida.
var ruta_guardado := RUTA_GUARDADO


func _ready() -> void:
	cargar()


func esta_liberado(pueblo_id: int) -> bool:
	return pueblos_liberados.has(pueblo_id)


## El jefe solo aparece cuando Chispita ha vencido a los nueve secuaces.
func jefe_desbloqueado() -> bool:
	for pueblo_id in TOTAL_SECUACES:
		if not esta_liberado(pueblo_id):
			return false
	return true


## Tabla que repasa cada pueblo de secuaz: el Pueblo 1 es la del 2 y el 9 la del 10.
func tabla_del_pueblo(pueblo_id: int) -> int:
	return PRIMERA_TABLA + pueblo_id


func tablas_secuaces() -> Array[int]:
	var tablas: Array[int] = []
	for tabla in range(PRIMERA_TABLA, ULTIMA_TABLA + 1):
		tablas.append(tabla)
	return tablas


func fallos_de(pregunta: Pregunta) -> int:
	return int(fallos.get(pregunta.clave, 0))


func registrar_fallo(pregunta: Pregunta) -> void:
	fallos[pregunta.clave] = fallos_de(pregunta) + 1
	guardar()


func liberar_pueblo(pueblo_id: int) -> void:
	if not esta_liberado(pueblo_id):
		pueblos_liberados.append(pueblo_id)
		guardar()


func reiniciar() -> void:
	pueblos_liberados.clear()
	fallos.clear()
	guardar()


func guardar() -> void:
	var config := ConfigFile.new()
	config.set_value("partida", "version", VERSION_PARTIDA)
	config.set_value("partida", "pueblos_liberados", pueblos_liberados)
	config.set_value("partida", "fallos", fallos)
	var error := config.save(ruta_guardado)
	if error != OK:
		push_error(
			"No se pudo guardar %s: %s" % [ruta_guardado, error_string(error)]
		)


func cargar() -> void:
	var config := ConfigFile.new()
	if config.load(ruta_guardado) != OK:
		return

	var version := 0
	var version_guardada: Variant = config.get_value("partida", "version", 0)
	if version_guardada is int or version_guardada is float:
		version = int(version_guardada)
	if version < VERSION_PARTIDA:
		# Las tablas de los pueblos cambiaron: el avance viejo ya no significa
		# lo mismo, asi que se empieza de cero como al pulsar "Limpiar Progreso".
		reiniciar()
		return

	pueblos_liberados = _leer_pueblos(
		config.get_value("partida", "pueblos_liberados", [])
	)
	fallos = _leer_fallos(config.get_value("partida", "fallos", {}))


## Solo acepta ids de pueblo validos, sin duplicados y en el rango del juego.
func _leer_pueblos(valor: Variant) -> Array[int]:
	var pueblos: Array[int] = []
	if not valor is Array:
		return pueblos
	for item in valor:
		if not (item is int or (item is float and item == floorf(item))):
			continue
		var pueblo := int(item)
		if pueblo < 0 or pueblo >= TOTAL_PUEBLOS or pueblos.has(pueblo):
			continue
		pueblos.append(pueblo)
	return pueblos


## Solo acepta claves de texto y contadores numericos no negativos.
func _leer_fallos(valor: Variant) -> Dictionary:
	var leidos: Dictionary = {}
	if not valor is Dictionary:
		return leidos
	for clave in valor:
		if not clave is String:
			continue
		var cantidad: Variant = valor[clave]
		if not (cantidad is int or (cantidad is float and cantidad == floorf(cantidad))):
			continue
		leidos[clave] = maxi(int(cantidad), 0)
	return leidos

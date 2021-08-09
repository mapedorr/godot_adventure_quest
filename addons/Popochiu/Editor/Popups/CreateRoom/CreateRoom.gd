tool
extends CreationPopup
# Permite crear una nueva habitación con los archivos necesarios para que funcione
# en el Popochiu: RoomRRR.tscn, RoomRRR.gd, RoomRRR.tres.

# TODO: Definir más propiedades en el popup de creación de la habitación: p. ej.
#		si va a tener al player, o los límites de la cámara. Aunque eso ya se
#		puede hacer una vez se abra el .tscn.

const BASE_ROOM_PATH := 'res://src/Nodes/Room/Room.tscn'

var _new_room_name := ''
var _new_room_path := ''
var _room_path_template := ''


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	_clear_fields()


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos virtuales ░░░░
func set_main_dock(node: PopochiuDock) -> void:
	.set_main_dock(node)
	# Por defecto: res://src/Rooms
	_room_path_template = _main_dock.rooms_path + '%s/Room%s'


func create() -> void:
	if not _new_room_name:
		_error_feedback.show()
		return
	
	# TODO: Verificar si no hay ya una habitación en el mismo PATH.
	# TODO: Eliminar archivos creados si la creación no se completa.
	
	# Crear el directorio donde se guardará la nueva habitación ----------------
	_main_dock.dir.make_dir(_main_dock.rooms_path + _new_room_name)

	# Crear el script de la nueva habitación -----------------------------------
	var room_template := load('res://script_templates/RoomTemplate.gd')
	if ResourceSaver.save(_new_room_path + '.gd', room_template) != OK:
		push_error('No se pudo crear el script de la habitación: %s' %\
		_new_room_name)
		# TODO: Mostrar retroalimentación en el mismo popup
		return

	# Crear la instancia de la nueva habitación y asignarle el script creado ---
	var new_room: Room = preload(BASE_ROOM_PATH).instance()
	#	Primero se asigna el script para que no se vayan a sobrescribir otras
	#	propiedades por culpa de esa asignación.
	new_room.set_script(load(_new_room_path + '.gd'))
	new_room.script_name = _new_room_name
	new_room.name = 'Room' + _new_room_name
	
	# Crear el archivo de la escena --------------------------------------------
	var new_room_packed_scene: PackedScene = PackedScene.new()
	new_room_packed_scene.pack(new_room)
	if ResourceSaver.save(_new_room_path + '.tscn', new_room_packed_scene) != OK:
		push_error('No se pudo crear la habitación: %s' % _new_room_name)
		# TODO: Mostrar retroalimentación en el mismo popup
		return
	
	# Crear el Resource de la habitación ---------------------------------------
	var room_resource: PopochiuRoom = PopochiuRoom.new()
	room_resource.script_name = _new_room_name
	room_resource.scene = _new_room_path + '.tscn'
	room_resource.resource_name = _new_room_name
	if ResourceSaver.save(_new_room_path + '.tres', room_resource) != OK:
		push_error('No se pudo crear el PopochiuRoom de la habitación: %s' %\
		_new_room_name)
		# TODO: Mostrar retroalimentación en el mismo popup
		return

	# Agregar la habitación al Popochiu ----------------------------------------
	var popochiu: Node = ResourceLoader.load(_main_dock.POPOCHIU_SCENE).instance()
	popochiu.rooms.append(ResourceLoader.load(_new_room_path + '.tres'))
	var new_popochiu: PackedScene = PackedScene.new()
	new_popochiu.pack(popochiu)
	if ResourceSaver.save(_main_dock.POPOCHIU_SCENE, new_popochiu) != OK:
		push_error('No se pudo agregar la habitación a GAQ: %s' %\
		_new_room_name)
		# TODO: Mostrar retroalimentación en el mismo popup
		return
	_main_dock.ei.reload_scene_from_path(_main_dock.POPOCHIU_SCENE)
	
	# Actualizar la lista de habitaciones en el Dock ---------------------------
	_main_dock.add_to_list('room', _new_room_name)
	
	# Abrir la escena creada en el editor --------------------------------------
	yield(get_tree().create_timer(0.1), 'timeout')
	_main_dock.ei.select_file(_new_room_path + '.tscn')
	_main_dock.ei.open_scene_from_path(_new_room_path + '.tscn')
	
	# Fin
	hide()

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _update_name(new_text: String) -> void:
	._update_name(new_text)

	if _name:
		_new_room_name = _name
		_new_room_path = _room_path_template % [_new_room_name, _new_room_name]

		_info.bbcode_text = (
			'En [b]%s[/b] se crearán los archivos:\n[code]%s, %s y %s[/code]' \
			% [
				_main_dock.rooms_path + _new_room_name,
				'Room' + _new_room_name + '.tscn',
				'Room' + _new_room_name + '.gd',
				'Room' + _new_room_name + '.tres'
			])
	else:
		_info.clear()


func _clear_fields() -> void:
	._clear_fields()
	
	_new_room_name = ''
	_new_room_path = ''
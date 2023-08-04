extends 'res://addons/popochiu/editor/factories/factory_base_popochiu_room_obj.gd'
class_name PopochiuRegionFactory

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ PUBLIC ░░░░
func _init(_main_dock: Panel) -> void:
	super(_main_dock)
	_obj_type = Constants.Types.REGION
	_obj_type_label = 'region'
	_obj_room_group = 'Regions'
	_obj_path_template = '/regions/%s/region_%s'


func create(obj_name: String, room: PopochiuRoom) -> int:
	# If everything goes well, this won't change.
	var result_code := ResultCodes.SUCCESS

	_setup_room(room)
	_setup_name(obj_name)

	# Create the folder for the Region
	result_code = _create_obj_folder()
	if result_code != ResultCodes.SUCCESS: return result_code
	
	# Create the script for the Region
	result_code = _copy_script_template()
	if result_code != ResultCodes.SUCCESS: return result_code

	# ▓▓▓ LOCAL CODE ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
	# Create the region instance
	var new_obj: PopochiuRegion = _load_obj_base_scene()

	new_obj.name = _obj_pascal_name
	new_obj.script_name = _obj_pascal_name
	new_obj.description = _obj_snake_name.capitalize()

	# Save the region scene (.tscn) and put it into _obj_scene class property
	result_code = _save_obj_scene(new_obj)
	if result_code != ResultCodes.SUCCESS: return result_code

	# TODO: Introduce here the logic to handle children in scene
	# Create the collision polygon for the region
	var collision := CollisionPolygon2D.new()
	collision.name = 'InteractionPolygon'
	collision.modulate = Color.CYAN
	_obj_scene.add_child(collision)
	# ▓▓▓ END OF LOCAL CODE ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

	# Add the hotspot to its room
	_add_resource_to_room()

	return result_code

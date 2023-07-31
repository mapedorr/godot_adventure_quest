extends 'res://addons/popochiu/editor/factories/factory_base_popochiu_room_obj.gd'
class_name PopochiuWalkableAreaFactory

# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ PUBLIC ░░░░
func _init(_main_dock: Panel) -> void:
	super(_main_dock)
	_obj_type = Constants.Types.WALKABLE_AREA
	_obj_type_label = 'walkable_area'
	_obj_room_group = 'WalkableAreas'
	_obj_path_template = '/walkable_areas/%s/walkable_area_%s'


func create(obj_name: String, room: PopochiuRoom) -> PopochiuWalkableArea:
	_setup_room(room)
	_setup_name(obj_name)
	
	# Create the folder for the WalkableArea
	if _create_obj_folder() == ResultCodes.FAILURE: return
	
	# Create the script for the WalkableArea
	if _copy_script_template() == ResultCodes.FAILURE: return
	
	# ▓▓▓ LOCAL CODE ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
	# Create the new walkable area instance
	var new_obj: PopochiuWalkableArea = _load_obj_base_scene()

	new_obj.name = _obj_pascal_name
	new_obj.script_name = _obj_pascal_name
	new_obj.description = _obj_snake_name.capitalize()

	# Save the region scene (.tscn) and put it into _obj class property
	if _save_obj_scene(new_obj) == ResultCodes.FAILURE: return

	# Create the NavigationRegion2D
	var perimeter := NavigationRegion2D.new()
	perimeter.name = 'Perimeter'
	var polygon := NavigationPolygon.new()
	polygon.add_outline(PackedVector2Array([
		Vector2(-10, -10), Vector2(10, -10), Vector2(10, 10), Vector2(-10, 10)
	]))
	polygon.make_polygons_from_outlines()
	perimeter.navpoly = polygon
	perimeter.modulate = Color.GREEN
	_obj.add_child(perimeter)
	# ▓▓▓ END OF LOCAL CODE ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

	# Add the prop to its room
	_add_resource_to_room()

	# This factory returns the object itself
	return _obj
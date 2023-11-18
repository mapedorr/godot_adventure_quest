@tool
extends VBoxContainer

const COMPONENTS_PATH :=\
"res://addons/popochiu/engine/objects/graphic_interface/components/"

var main_dock: Panel

var _opened_scene: Control = null
var _components_basedir := []
var _script_path := PopochiuResources.GRAPHIC_INTERFACE_POPOCHIU.replace(".tscn", ".gd")
var _commands_path := PopochiuResources.GRAPHIC_INTERFACE_POPOCHIU.replace(
	"graphic_interface.tscn", "commands.gd"
)

@onready var template_name: Label = %TemplateName
@onready var btn_script: Button = %BtnScript
@onready var btn_commands: Button = %BtnCommands


#region Godot
func _ready() -> void:
	btn_script.icon = get_theme_icon('Script', 'EditorIcons')
	btn_commands.icon = get_theme_icon('Script', 'EditorIcons')
	
	# Connect to child signals
	btn_script.pressed.connect(_on_script_pressed)
	btn_commands.pressed.connect(_on_commands_pressed)
	%PopupsGroup.create_clicked.connect(_on_create_popup_clicked)


#endregion

#region Public
## Called when the selected scene in the Editor 2D changes.
## This checks if that scene is a PopochiuGraphicInterface to list its components
## and create the corresponding buttons to add/remove such components.
func on_scene_changed(gui_node: Node) -> void:
	if gui_node is PopochiuGraphicInterface:
		_opened_scene = gui_node
		
		# FIXME: This override the tab change done by tab_room.gd
		get_parent().current_tab = get_index()
		
		_clear_elements()
		
		await get_tree().process_frame
		
		_read_dir(COMPONENTS_PATH)
		_create_buttons()
		_find_components(gui_node)
		_update_groups_titles()
		
		template_name.text = "Template: %s" % (
			PopochiuResources.get_data_value("ui", "template", "---") as String
		).capitalize()
		
		_opened_scene.child_exiting_tree.connect(_on_child_removed)
		
		var popups := _opened_scene.get_node_or_null("Popups")
		if popups:
			popups.child_exiting_tree.connect(_on_child_removed)
	else:
		if is_instance_valid(_opened_scene):
			_opened_scene.child_exiting_tree.disconnect(_on_child_removed)
			
			var popups := _opened_scene.get_node_or_null("Popups")
			if popups:
				popups.child_exiting_tree.disconnect(_on_child_removed)
		
		_opened_scene = null


## Opens the graphic interface scene of the game.
func open_gui_scene() -> void:
	if is_instance_valid(_opened_scene)\
	and _opened_scene is PopochiuGraphicInterface:
		return
	
	var path := PopochiuResources.GRAPHIC_INTERFACE_POPOCHIU
	
	main_dock.ei.select_file(path)
	main_dock.ei.set_main_screen_editor('2D')
	main_dock.ei.open_scene_from_path(path)


#endregion

#region Private
func _on_script_pressed() -> void:
	main_dock.ei.select_file(_script_path)
	main_dock.ei.set_main_screen_editor('Script')
	main_dock.ei.edit_script(load(_script_path))


func _on_commands_pressed() -> void:
	main_dock.ei.select_file(_commands_path)
	main_dock.ei.set_main_screen_editor('Script')
	main_dock.ei.edit_script(load(_commands_path))


func _on_create_popup_clicked() -> void:
	$CreatePopupWindow.popup_centered()


func _clear_elements() -> void:
	_components_basedir.clear()
	for container in [%BaseComponentsGroup, %PopupsGroup]:
		container.clear_list()


## Reads a directory in the project (addons folder) looking for Popochiu GUI
## components and popups.
func _read_dir(path: String) -> void:
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		
		var element_name = dir.get_next()
		while element_name != "":
			if dir.current_is_dir():
				if element_name == "popups":
					_read_dir(COMPONENTS_PATH + element_name + "/")
				else:
					_components_basedir.append(path + element_name)
			
			element_name = dir.get_next()


func _create_buttons() -> void:
	for component_path in _components_basedir:
		var btn := Button.new()
		var component_name: String = component_path.split("/")[-1]
		
		btn.name = component_name
		btn.text = component_name.capitalize()
		btn.set_meta("path", component_path)
		btn.pressed.connect(_add_component.bind(btn))
		
		if component_path.find("popups") >= 0:
			%PopupsGroup.add(btn)
		else:
			%BaseComponentsGroup.add(btn)
		
		set_meta(component_name, btn)


func _find_components(node: Control) -> void:
	for child in node.get_children():
		if child.name == "Popups":
			_find_components(child)
			continue
		
		var is_component := child.scene_file_path.get_base_dir() in _components_basedir
		
		if not is_component:continue
		
		var component_name := child.scene_file_path.get_base_dir().split("/")[-1]
		if has_meta(component_name):
			(get_meta(component_name) as Button).disabled = true


func _update_groups_titles() -> void:
	var disabled_count := 0
	for btn in %BaseComponentsGroup.get_elements():
		if btn.disabled:
			disabled_count += 1
	
	%BaseComponentsGroup.set_title_count(
		disabled_count, %BaseComponentsGroup.get_elements().size()
	)
	
	disabled_count = 0
	for btn in %PopupsGroup.get_elements():
		if btn.disabled:
			disabled_count += 1
	
	%PopupsGroup.set_title_count(
		disabled_count, %PopupsGroup.get_elements().size()
	)


func _add_component(btn: Button) -> void:
	btn.disabled = true
	
	var is_popup: bool = btn.get_meta("path").find("popups") >= 0
	var scene_path := "%s/%s.tscn" % [
		btn.get_meta("path"),
		btn.name + "_popup" if is_popup else btn.name
	]
	
	var instance: Control = load(scene_path).instantiate()
	
	if is_popup:
		if not _opened_scene.get_node_or_null("Popups"):
			var popups_group := Control.new()
			
			_opened_scene.add_child(popups_group)
			
			popups_group.name = "Popups"
			popups_group.owner = _opened_scene
			popups_group.layout_mode = 1
			popups_group.anchors_preset = PRESET_FULL_RECT
			popups_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		_opened_scene.get_node('Popups').add_child(instance)
	else:
		_opened_scene.add_child(instance)
	
	instance.owner = _opened_scene
	
	var result: int = PopochiuUtils.ei.save_scene()
	
	if result == OK:
		PopochiuUtils.select_node(instance)
	else:
		btn.disabled = false


func _on_child_removed(node: CanvasItem) -> void:
	if not node is Control: return
	
	var basedir := node.scene_file_path.get_base_dir()
	if basedir in _components_basedir:
		(get_meta(basedir.split("/")[-1]) as Button).disabled = false


#endregion

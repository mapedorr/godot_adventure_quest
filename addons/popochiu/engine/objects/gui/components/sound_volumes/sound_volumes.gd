extends GridContainer

const MIN_VOLUME := -30
const MUTE_VOLUME := -70

var dflt_volumes := {}


#region Godot ######################################################################################
func _ready() -> void:
	# Connect to AudioManager ready signal
	PopochiuUtils.e.am.ready.connect(_on_audio_manager_ready)


#endregion

#region Public #####################################################################################
func update_sliders() -> void:
	for slider in $SlidersContainer.get_children():
		if not slider.has_meta("bus_name"): continue
		
		var bus_name: String = slider.get_meta("bus_name")
		
		slider.value = PopochiuUtils.e.am.volume_settings[bus_name]
		dflt_volumes[bus_name] = slider.value


func restore_last_volumes() -> void:
	for slider in $SlidersContainer.get_children():
		if not slider.has_meta("bus_name"): continue
		
		var bus_name: String = slider.get_meta("bus_name")
		PopochiuUtils.e.am.set_bus_volume_db(bus_name, dflt_volumes[bus_name])


#endregion

#region Private ####################################################################################
func _on_audio_manager_ready() -> void:
	PopochiuUtils.e.am.load_sound_settings()
	
	# Build sound settings UI
	for bus_idx in range(AudioServer.get_bus_count()):
		var bus_name := AudioServer.get_bus_name(bus_idx)
		# Create the label for the slider
		var label := Label.new()
		label.text = bus_name
		
		$ChannelsContainer.add_child(label)
		
		# Create the node that will allow players to modify buses volumes
		var slider = HSlider.new()
		slider.min_value = MIN_VOLUME
		slider.max_value = 0
		slider.value = PopochiuUtils.e.am.volume_settings[bus_name]
		slider.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.size_flags_vertical = Control.SIZE_EXPAND_FILL
		slider.custom_minimum_size.x = 120.0
		slider.set_meta("bus_name", bus_name)
		
		$SlidersContainer.add_child(slider)
		
		slider.value_changed.connect((
			func (value: float, bus_name_param: String):
				@warning_ignore("standalone_ternary")
				PopochiuUtils.e.am.set_bus_volume_db(
					bus_name_param,
					value if value > MIN_VOLUME else MUTE_VOLUME
				)
		).bind(bus_name))


#endregion

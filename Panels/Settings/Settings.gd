extends Control

var config_file := ConfigFile.new()

var settings : Dictionary = {
	"Display":{
		"scale_factor":{
			"input":SpinBox,
			"configs":{
				"min_value":1,
				"max_value":5,
				"rounded":true,
			},
			"function":self.set_scale_factor,
			"signal":"value_changed",
			"tooltip":"Set the UI scale",
			"setter":"set_value_no_signal"
		},
		"VSync":{
			"input":CheckButton,
			"function":self.set_vsync,
			"signal":"toggled",
			"tooltip":"Use VSync",
			"setter":"set_pressed_no_signal"
		}
	}
}

#func _ready() -> void:
	#config_file.load("user://spectrum.cfg")
	#Interface.configFile = config_file
	#load_settings()

func load_settings() -> void:
	for section in settings.keys():
		var section_node := add_section_node(section)
		for setting in settings[section].keys():
			var config : Dictionary = settings[section][setting]
			var value : Variant = config_file.get_value(section, setting, "")
			if value:
				config.function.call(value)
			var input_node = add_setting_node(section_node, setting, value, config.input, config.signal, config.function, config.setter, config.get("configs", {}), config.get("tooltip", ""))
			
			config.node = input_node
			
func add_section_node(name:String) -> VBoxContainer:
	var scroll_container := ScrollContainer.new()
	var margin_container := MarginContainer.new()
	var box_container := VBoxContainer.new()
	scroll_container.name = name
	scroll_container.follow_focus = true
	margin_container.add_theme_constant_override("margin_right", 4)
	margin_container.add_theme_constant_override("margin_left", 4)
	margin_container.add_theme_constant_override("margin_top", 4)
	margin_container.add_theme_constant_override("margin_bottom", 4)
	margin_container.add_child(box_container)
	margin_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	scroll_container.add_child(margin_container)
	scroll_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	$TabContainer.add_child(scroll_container)
	return box_container

func add_setting_node(section:Control, name:String, value:Variant, input_type, signal_to_connect:String, signal_callback:Callable, setter:StringName, configs:Dictionary={}, tooltip_text:String="") -> Control:
	var panel_container_node : PanelContainer = PanelContainer.new()
	var box_container_node : HBoxContainer = HBoxContainer.new()
	var label_node := Label.new()
	var input_node : Control = input_type.new()
	
	panel_container_node.custom_minimum_size = Vector2(0, 50)
	
	label_node.text = name.capitalize()
	
	input_node.tooltip_text = tooltip_text
	input_node.get(signal_to_connect).connect(signal_callback)
	
	for key in configs.keys():
		if key in input_node:
			input_node.set(key, configs[key])
	
	if value:
		input_node.get(setter).call(value)
	
	label_node.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	input_node.set_h_size_flags(Control.SIZE_SHRINK_END)
	box_container_node.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	box_container_node.add_child(label_node)
	box_container_node.add_child(input_node)
	panel_container_node.add_child(box_container_node)
	section.add_child(panel_container_node)
	
	return input_node

func save() -> void:
	config_file.save("user://spectrum.cfg")

func set_scale_factor(value:int) -> void:
	config_file.set_value("Display", "scale_factor", value)
	get_tree().root.set_content_scale_factor(value)
	save()

func set_vsync(enabled:bool) -> void:
	config_file.set_value("Display", "vsync", enabled)
	DisplayServer.window_set_vsync_mode((DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED))
	save()

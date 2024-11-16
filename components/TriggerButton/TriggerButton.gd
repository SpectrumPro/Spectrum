# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name TriggerButton extends Button
## Ui button to trigger an action on click


## Emitted when the name is changed
signal name_changed(new_name: String)

## Emitted when the background color is changed
signal bg_color_changed(bg_color: Color)

## Emitted when the border color is changed
signal border_color_changed(border_color: Color)

## Emitted when the border width is changed
signal border_width_changed(border_width: int)


## Button Mode
enum Mode {Normal, Toggle}
var button_mode: Mode = Mode.Normal : set = set_button_mode


## Stored here so the indicator can be resized
var _percentage: float = 0

## The style box used for themeing this button
var _style_box: StyleBoxFlat = null


## The default button config, stored here so it can be used to reset the config if needed
var _default_button_config: Dictionary = {
	"uuid": "",
	"method_name": "",
	"args": [],
	"callable": Callable()
}

## Config for the button up action
var _button_up_config: Dictionary = _default_button_config.duplicate()

## Config for the button down action1
var _button_down_config: Dictionary = _default_button_config.duplicate()


func _ready() -> void:
	_style_box = $Style.get_theme_stylebox("panel").duplicate()
	$Style.add_theme_stylebox_override("panel", _style_box)


## Sets the text of this button, 
## use this instead of buttons built in set_text method, as this label supports text wrapping
func set_label_text(label_text: String) -> void:
	$Label.text = label_text
	name_changed.emit(label_text)


## Gets the label text
func get_label_text() -> String:
	return $Label.text


## Sets and gets the background color
func set_bg_color(bg_color: Color) -> void: 
	_style_box.bg_color = bg_color
	bg_color_changed.emit(bg_color)

func get_bg_color() -> Color: return _style_box.bg_color


## Sets and gets the border color
func set_border_color(border_color: Color) -> void: 
	_style_box.border_color = border_color
	border_color_changed.emit(border_color)

func get_border_color() -> Color: return _style_box.border_color


## Sets and gets the border width
func set_border_width(border_width: int) -> void:
	_style_box.border_width_left = border_width
	_style_box.border_width_right = border_width
	_style_box.border_width_top = border_width
	_style_box.border_width_bottom = border_width
	border_width_changed.emit(border_width)

func get_border_width() -> int: return _style_box.border_width_bottom


## Sets the button mode
func set_button_mode(p_button_mode: Mode) -> void:
	button_mode = p_button_mode
	toggle_mode = p_button_mode == Mode.Toggle
	
	if toggle_mode:
		if button_up.is_connected(_on_button_up): button_up.disconnect(_on_button_up)
		if button_down.is_connected(_on_button_down): button_down.disconnect(_on_button_down)
		if not toggled.is_connected(_on_button_toggled): toggled.connect(_on_button_toggled)
		
	
	else:
		if not button_up.is_connected(_on_button_up): button_up.connect(_on_button_up)
		if not button_down.is_connected(_on_button_down): button_down.connect(_on_button_down)
		if toggled.is_connected(_on_button_toggled): toggled.disconnect(_on_button_toggled)


## Sets the action for button up
func set_button_up(component_uuid: String, method_name: String, args: Array) -> void:
	if _button_up_config.uuid:
		ComponentDB.remove_request(_button_up_config.uuid, _on_button_up_object_found)
	
	_button_up_config.uuid = component_uuid
	_button_up_config.method_name = method_name
	_button_up_config.args = args
	
	ComponentDB.request_component(component_uuid, _on_button_up_object_found)


## Removes the button up binding
func remove_button_up() -> void:
	if _button_up_config.uuid:
		ComponentDB.remove_request(_button_up_config.uuid, _on_button_up_object_found)
	
	_button_up_config = _default_button_config.duplicate()


## Returns the button up config
func get_button_up() -> Dictionary: return _button_up_config.duplicate()


## Callback for when ComponentDB finds the object
func _on_button_up_object_found(object: EngineComponent) -> void:
	if object.accessible_methods.get(_button_up_config.method_name):
		_button_up_config.callable = object.accessible_methods[_button_up_config.method_name].set.bindv(_button_up_config.args)


## Sets the action for button down
func set_button_down(component_uuid: String, method_name: String, args: Array) -> void:
	if _button_down_config.uuid:
		ComponentDB.remove_request(_button_down_config.uuid, _on_button_down_object_found)
	
	_button_down_config.uuid = component_uuid
	_button_down_config.method_name = method_name
	_button_down_config.args = args
	
	ComponentDB.request_component(component_uuid, _on_button_down_object_found)


## Removes the button down binding
func remove_button_down() -> void:
	if _button_down_config.uuid:
		ComponentDB.remove_request(_button_down_config.uuid, _on_button_down_object_found)
	
	_button_down_config = _default_button_config.duplicate()


## Returns the button down config
func get_button_down() -> Dictionary: return _button_down_config.duplicate()


## Callback for when ComponentDB finds the object
func _on_button_down_object_found(object: EngineComponent) -> void:
	if object.accessible_methods.get(_button_down_config.method_name):
		_button_down_config.callable = object.accessible_methods[_button_down_config.method_name].set.bindv(_button_down_config.args)


## Sets the indicator value of this button
func set_value(percentage: float) -> void:
	_percentage = percentage
	$Value.set_deferred("size", Vector2(remap(percentage, 0, 1, 0, size.x), size.y))


## Makes this trigger button a dummy of another, will auto copy over visual elements, but not triggers
func make_dummy_of(master_trigger: TriggerButton) -> void:
	set_label_text(master_trigger.get_label_text())
	set_bg_color(master_trigger.get_bg_color())
	set_border_color(master_trigger.get_border_color())
	set_border_width(master_trigger.get_border_width())
	
	master_trigger.name_changed.connect(set_label_text)
	master_trigger.bg_color_changed.connect(set_bg_color)
	master_trigger.border_color_changed.connect(set_border_color)
	master_trigger.border_width_changed.connect(set_border_width)


## Used to update the position of the value background when we are resized
func _on_resized() -> void: set_value(_percentage)


## Called when this button is pushed down
func _on_button_down() -> void:
	if _button_down_config.callable.is_valid():
		_button_down_config.callable.call()


## Called when this button is let go
func _on_button_up() -> void:
	if _button_up_config.callable.is_valid():
		_button_up_config.callable.call()


## Called when this button is toggled in toggle mode, will call the corresponding _on_button_* method
func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_on_button_down()
	else:
		_on_button_up()


## Saves the config of this TriggerButton into a dict
func serialize() -> Dictionary:
	return {
		"button_mode": button_mode,
		"button_down": {
			"uuid": _button_down_config.uuid,
			"method_name": _button_down_config.method_name,
			"args": _button_down_config.args
		},
		"button_up": {
			"uuid": _button_up_config.uuid,
			"method_name": _button_up_config.method_name,
			"args": _button_up_config.args
		},
		"label": $Label.text,
		"bg_color": var_to_str(get_bg_color()),
		"border_color": var_to_str(get_border_color()),
		"border_width": get_border_width(),
		"visible": visible,
	}


## Loads the saved state
func deserialize(serialized_data: Dictionary) -> void:
	set_button_mode(serialized_data.get("button_mode", Mode.Normal))
	
	if serialized_data.get("button_down", null) is Dictionary: 
		var config: Dictionary = serialized_data.button_down
		if config.get("uuid", "") and config.get("method_name", "") and config.get("args", []) is Array:
			set_button_down(
				config.uuid,
				config.method_name,
				config.get("args", [])
			)
	
	if serialized_data.get("button_up", null) is Dictionary: 
		var config: Dictionary = serialized_data.button_up
		if config.get("uuid", "") and config.get("method_name", "") and config.get("args", []) is Array:
			print("Up: ", config.method_name)
			set_button_up(
				config.uuid,
				config.method_name,
				config.get("args", [])
			)
	
	var bg = str_to_var(serialized_data.get("bg_color", ""))
	if bg is Color: set_bg_color(bg)
	
	var border = str_to_var(serialized_data.get("border_color", ""))
	if border is Color: set_border_color(border)
	
	set_border_width(serialized_data.get("border_width", get_border_width()))
	
	set_label_text(serialized_data.get("label", ""))
	visible = serialized_data.get("visible", true)

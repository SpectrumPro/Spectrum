# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name TriggerButton extends Button
## Ui button to trigger an action on click


## Button Mode
enum Mode {Normal, Toggle}
var button_mode: Mode = Mode.Normal : set = set_button_mode


## Stored here so the indicator can be resized
var _percentage: float = 0

## Config for the button up action
var _button_up_config: Dictionary = {
	"uuid": "",
	"method_name": "",
	"args": [],
	"callable": Callable()
}


## Config for the button down action
var _button_down_config: Dictionary = {
	"uuid": "",
	"method_name": "",
	"args": [],
	"callable": Callable()
}


## Sets the text of this button, 
## use this instead of buttons built in set_text methord, as this label supports text wrapping
func set_label_text(label_text: String) -> void:
	$Label.text = label_text


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


## Callback for when ComponentDB finds the object
func _on_button_up_object_found(object: EngineComponent) -> void:
	if object.get(_button_up_config.method_name) is Callable:
		_button_up_config.callable = object.get(_button_up_config.method_name).bindv(_button_up_config.args)


## Sets the action for button down
func set_button_down(component_uuid: String, method_name: String, args: Array) -> void:
	if _button_down_config.uuid:
		ComponentDB.remove_request(_button_down_config.uuid, _on_button_down_object_found)
	
	_button_down_config.uuid = component_uuid
	_button_down_config.method_name = method_name
	_button_down_config.args = args
	
	ComponentDB.request_component(component_uuid, _on_button_down_object_found)


## Callback for when ComponentDB finds the object
func _on_button_down_object_found(object: EngineComponent) -> void:
	if object.get(_button_down_config.method_name) is Callable:
		_button_down_config.callable = object.get(_button_down_config.method_name).bindv(_button_down_config.args)


## Sets the indicator value of this button
func set_value(percentage: float) -> void:
	_percentage = percentage
	$Value.set_deferred("size", Vector2(remap(percentage, 0, 1, 0, size.x), size.y))


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
			set_button_up(
				config.uuid,
				config.method_name,
				config.get("args", [])
			)
	
	set_label_text(serialized_data.get("label", ""))
	visible = serialized_data.get("visible", true)

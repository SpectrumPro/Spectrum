# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name ParameterController extends PanelContainer
## Controls a parameter of a fixrure


## Emitted when the value is changed
signal value_changed(parameter: String, value: float)


## FunctionList node for displaying all parameter functions
@export var _function_list: OptionButton

## The VSlider node for changing a parameter's value
@export var _slider: VSlider

## The NameLabel for the parameter
@export var _name_label: Label


## The parameter this ParameterController controls
var _parameter: String = ""


## Sets the parameter
func set_parameter(parameter: String) -> void:
	_parameter = parameter
	_name_label.text = parameter


## Adds an item to the function list
func add_function(function: String) -> void:
	_function_list.add_item(function)
	_function_list.selected = 1


## Clears this ParameterController
func clear() -> void:
	_function_list.clear()
	_slider.set_value_no_signal(0)
	_parameter = ""


## Called when the slider value changes
func _on_v_slider_value_changed(value: float) -> void:
	if _parameter:
		var parameter: String = _parameter
		
		if _function_list.get_selected_id() != -1:
			parameter += "." + _function_list.get_item_text(_function_list.get_selected_id())
		
		value_changed.emit(parameter, value)
		print(parameter, value)

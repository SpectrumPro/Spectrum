# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name ParameterController extends PanelContainer
## Controls a parameter of a fixrure


## Emitted when the value is changed
signal value_changed(parameter: String, function: String, value: float)

## Emitted when the erase is pressed
signal erase_pressed(parameter: String)

## Emitted when the random button is pressed
signal random_pressed(parameter: String, function: String)


## FunctionList node for displaying all parameter functions
@export var _function_list: OptionButton

## The VSlider node for changing a parameter's value
@export var _slider: VSlider

## The NameLabel for the parameter
@export var _name_label: Label

## The zone label
@export var _zone_label: Label

## TitleBar PanelContainer
@export var _title_bar: PanelContainer


## The category of this parameter
var category: String = ""

## The parameter this ParameterController controls
var _parameter: String = ""

## The zone of this parameter
var _zone: String = ""

## All the current displayed functions
var _functions: Array[String]

## The StyleBoxFlat for the title
var _title_stylebox: StyleBoxFlat = null

## Default color of this ParameterController
var _default_color: Color = Color(0.129, 0.129, 0.129)

## Override color of this ParameterController
var _override_color: Color = Color(1, 0.518, 0)


func _ready() -> void:
	_title_stylebox = _title_bar.get_theme_stylebox("panel").duplicate()
	_title_bar.add_theme_stylebox_override("panel", _title_stylebox)


## Sets the parameter
func set_parameter(parameter: String) -> void:
	_parameter = parameter
	_name_label.text = parameter


## Sets the zone
func set_zone(zone: String) -> void:
	_zone = zone
	_zone_label.text = zone

## Sets the state of the override background
func set_override_bg(state: bool) -> void:
	if state:
		_title_stylebox.bg_color = _override_color
	else:
		_title_stylebox.bg_color = _default_color


## Sets the value of this parameter, no signal
func set_value(value: float) -> void:
	_slider.set_value_no_signal(value)


## Sets the current selected function
func set_function(function: String) -> void:
	_function_list.select(_functions.find(function))


## Adds an item to the function list
func add_function(function: String) -> void:
	_functions.append(function)
	_function_list.add_item(function)
	_function_list.selected = 1


## Checks if this ParameterController has a function:
func has_function(function: String) -> bool:
	return _functions.has(function)


## Gets the current selected function
func get_function() -> String:
	return _function_list.get_item_text(_function_list.get_selected_id())


## Clears this ParameterController
func clear() -> void:
	_functions.clear()
	_function_list.clear()
	
	_slider.set_value_no_signal(0)
	set_override_bg(false)


## Called when the slider value changes
func _on_v_slider_value_changed(value: float) -> void:
	if _parameter:
		value_changed.emit(_zone, _parameter, get_function(), value)


## Called when the Erace button is pressed
func _on_erase_pressed() -> void:
	erase_pressed.emit(_zone, _parameter)


## Called when the Random button is pressed
func _on_random_pressed() -> void:
	random_pressed.emit(_zone, _parameter, get_function())

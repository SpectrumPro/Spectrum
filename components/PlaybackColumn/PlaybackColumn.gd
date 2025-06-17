# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name PlaybackColumn extends PanelContainer
## The playback column container used in the playbacks panel


## Button 1
@export var button1: Button

## Button 2
@export var button2: Button

## Button 3
@export var button3: Button

## Button 4
@export var button4: Button

## Button 5
@export var button5: Button

## Button 6
@export var button6: Button

## Slider
@export var slider: VSlider


## The current FunctionGroup
var _function_group: FunctionGroup

## The EngineComponent asigned to this column
var _component: EngineComponent

## Row start index
var _row_start: int = 0

## Row Column
var _column: int

## Edit mode state
var _edit_mode: bool = false


## Bind Signals
func _ready() -> void:
	button1.pressed.connect(_on_button_pressed.bind(0))
	button2.pressed.connect(_on_button_pressed.bind(1))
	button3.pressed.connect(_on_button_pressed.bind(2))
	button4.pressed.connect(_on_button_pressed.bind(3))
	button5.pressed.connect(_on_button_pressed.bind(4))
	button6.pressed.connect(_on_button_pressed.bind(5))
	
	button1.button_down.connect(_on_button_down.bind(0))
	button2.button_down.connect(_on_button_down.bind(1))
	button3.button_down.connect(_on_button_down.bind(2))
	button4.button_down.connect(_on_button_down.bind(3))
	button5.button_down.connect(_on_button_down.bind(4))
	button6.button_down.connect(_on_button_down.bind(5))
	
	button1.button_up.connect(_on_button_up.bind(0))
	button2.button_up.connect(_on_button_up.bind(1))
	button3.button_up.connect(_on_button_up.bind(2))
	button4.button_up.connect(_on_button_up.bind(3))
	button5.button_up.connect(_on_button_up.bind(4))
	button6.button_up.connect(_on_button_up.bind(5))

## Sets the FunctionGroup
func set_function_group(function_group: FunctionGroup) -> void:
	_function_group = function_group


## Sets the column
func set_column(column: int) -> void:
	_column = column


## Sets the component
func set_component(component: EngineComponent) -> void:
	_component = component
	_set_disalbed(false)
	
	if _function_group:
		for row: int in range(_row_start, _row_start + 7):
			_function_group.remove_trigger(row, _column)


## Sets the edit mode state
func set_edit_mode(edit_mode: bool) -> void:
	_edit_mode = edit_mode


## Sets the disabled state of all buttons and sliders
func _set_disalbed(disabled: bool) -> void:
	button1.disabled = disabled
	button2.disabled = disabled
	button3.disabled = disabled
	slider.editable = not disabled
	button4.disabled = disabled
	button5.disabled = disabled
	button6.disabled = disabled


## Called when the Title Button is pressed
func _on_title_pressed() -> void:
	if _edit_mode:
		Interface.show_object_picker(ObjectPicker.SelectMode.Single, func (objects: Array):
			_component = objects[0]
			_set_disalbed(false)
		)


## Called when a button is clicked
func _on_button_pressed(button_index: int) -> void:
	if _edit_mode and _component:
		Interface.show_control_method_picker(_component).then(func (control_name: String):
			if control_name:
				var config: Dictionary = _component.get_control_method(control_name)
				_function_group.add_trigger(_component, config.up.get_method(), config.down.get_method(), control_name.capitalize(), _row_start + button_index, _column)
		)


## Called when a button is pressed down
func _on_button_down(button_index: int) -> void:
	if _function_group:
		_function_group.call_trigger_down(_row_start + button_index, _column)


## Called when a button is up
func _on_button_up(button_index: int) -> void:
	if _function_group:
		_function_group.call_trigger_up(_row_start + button_index, _column)

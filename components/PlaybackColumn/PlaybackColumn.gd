# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name PlaybackColumn extends PanelContainer
## The playback column container used in the playbacks panel


## The Title Button
@export var title_button: Button

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

## All buttons, with a null for the slider
@onready var _buttons: Array[Button] = [button1, button2, button3, null, button4, button5, button6]


## The current TriggerBlock
var _trigger_block: TriggerBlock

## The EngineComponent asigned to this column
var _component: EngineComponent

## Row start index
var _row_start: int = 0

## Row Column
var _column: int

## Edit mode state
var _edit_mode: bool = false

## Signals to connect to the component
var _component_signal_connections: Dictionary[String, Callable] = {
	"name_changed": _on_component_name_changed
}

## Bind Signals
func _ready() -> void:
	for button: Button in _buttons:
		if button:
			var index: int = _buttons.find(button)
			
			button.pressed.connect(_on_button_pressed.bind(index))
			button.button_down.connect(_on_button_down.bind(index))
			button.button_up.connect(_on_button_up.bind(index))
			
			(button.get_node("ID") as Label).set_text(str(_row_start + index) + "." + str(_column))


## Sets the FunctionGroup
func set_trigger_block(trigger_block: TriggerBlock) -> void:
	_trigger_block = trigger_block


## Sets the column
func set_column(column: int) -> void:
	_column = column


## Sets the component
func set_component(component: EngineComponent, no_remove: bool = false) -> void:
	if component == _component:
		return
	
	Utils.disconnect_signals(_component_signal_connections, _component)
	_component = component
	Utils.connect_signals(_component_signal_connections, _component)
	
	_set_disalbed(false)
	title_button.text = component.get_name()
	
	if _trigger_block and not no_remove:
		for row: int in range(_row_start, _row_start + 7):
			_trigger_block.remove_trigger(row, _column)


## Sets the edit mode state
func set_edit_mode(edit_mode: bool) -> void:
	_edit_mode = edit_mode
	title_button.disabled = not edit_mode


## Sets the name of a row
func set_row_name(row: int, p_name: String) -> void:
	if row == 3:
		pass # Slider
	
	elif row <= len(_buttons):
		var button: Button = _buttons[row]
		
		if button:
			button.set_text(p_name)


## Sets the disabled state of all buttons and sliders
func _set_disalbed(disabled: bool) -> void:
	title_button.disabled = disabled
	slider.editable = not disabled
	
	for button: Button in _buttons:
		if button:
			button.disabled = disabled


## Emitted when the component's name is changed
func _on_component_name_changed(new_name: String) -> void:
	title_button.set_text(new_name)


## Called when the Title Button is pressed
func _on_title_pressed() -> void:
	if _edit_mode:
		Interface.show_object_picker(ObjectPicker.SelectMode.Single, func (objects: Array):
			set_component(objects[0])
		)


## Called when a button is clicked
func _on_button_pressed(button_index: int) -> void:
	if _edit_mode and _component:
		Interface.show_control_method_picker(_component).then(func (control_name: String):
			if control_name:
				var config: Dictionary = _component.get_control_method(control_name)
				_trigger_block.add_trigger(_component, config.up.get_method(), config.down.get_method(), control_name.capitalize(), control_name, _row_start + button_index, _column)
		)


## Called when a button is pressed down
func _on_button_down(button_index: int) -> void:
	if _trigger_block and not _edit_mode:
		_trigger_block.call_trigger_down(_row_start + button_index, _column)


## Called when a button is up
func _on_button_up(button_index: int) -> void:
	if _trigger_block and not _edit_mode:
		_trigger_block.call_trigger_up(_row_start + button_index, _column)

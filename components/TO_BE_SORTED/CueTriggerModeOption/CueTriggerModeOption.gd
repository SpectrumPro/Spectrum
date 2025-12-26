# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name CueTriggerModeOption extends PanelContainer
## UI component to change the trigger mode on a cue


## The cue to modify
var cue: Cue = null : set = set_cue


## Contains all the buttons
@onready var _buttons: Array[Button] = [
	$HBoxContainer/Manual,
	$HBoxContainer/AfterLast,
	$HBoxContainer/WithLast
]

## The ButtonGroup, which all the buttons are apart of
var _button_group: ButtonGroup = ButtonGroup.new()


## Adds all the buttons to the ButtonGroup
func _ready() -> void:
	for button: Button in _buttons:
		button.button_group = _button_group
	
	if is_instance_valid(cue):
		_buttons[cue.trigger_mode].button_pressed = true


## Sets the cue to modify
func set_cue(p_cue: Cue) -> void:
	if p_cue != cue and p_cue:
		if cue:
			cue.trigger_mode_changed.disconnect(_on_cue_trigger_mode_changed)
		
		cue = p_cue
		cue.trigger_mode_changed.connect(_on_cue_trigger_mode_changed)


## Called when the cue's trigger mode is changed
func _on_cue_trigger_mode_changed(trigger_mode: Cue.TriggerMode) -> void:
	_buttons[trigger_mode].button_pressed = true


## Called when one of the buttons is pressed, an extra arg is passed for the index
func _on_button_pressed(extra_arg_0: int) -> void:
	cue.set_trigger_mode(extra_arg_0)

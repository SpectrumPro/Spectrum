# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name IntensityButton extends Button
## Button to change the intensity of a Function


## The max distance away from the center point
@export var max_distance: int = 800

## Multiplier of the value
@export var multiplier: float = 0.2


## The function to control
var function: Function = null : set = set_function


## The last value used
var _last_value: float = 0


## Disable the process at startup
func _ready() -> void: set_process(false)


## Sets the function
func set_function(p_function: Function) -> void:
	if is_instance_valid(function): function.intensity_changed.disconnect(_on_function_intensity_changed)
	function = p_function
	if is_instance_valid(function): 
		function.intensity_changed.connect(_on_function_intensity_changed)
		$ProgressBar.value = function.get_intensity()


## Calculates the mouse distance from the button, and adusts the intensity
func _process(delta: float) -> void:
	if is_instance_valid(function):
		var global_mouse: Vector2 = get_global_mouse_position()
		var center_position: Vector2 = global_position + (size / 2) 
		var change: float = remap(center_position.x - global_mouse.x, -max_distance, max_distance, -1, 1) * multiplier

		function.set_intensity(clamp(function.get_intensity() - change, 0, 1))
	
	if Input.is_action_just_released("left_click"):
		set_enabled(false)


## Sets the enabled state of this button
func set_enabled(state: bool) -> void:
	set_process(state)
	$Icon.visible = not state
	$ProgressBar.show_percentage = state


## Button callbacks
func _on_button_down() -> void: set_enabled(true)
func _on_button_up() -> void: set_enabled(false)


## Called when the intensity changes on the function
func _on_function_intensity_changed(intensity: float) -> void:
	$ProgressBar.value = intensity

# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

extends Control
## Simple encoder knob

signal value_changed(value:int) ## Emitted when the value is changed
signal movement_started ## Emitted when the user begins moving the knob
signal movement_ended ## Emitted when the user finishes moving the knob

@export var value: int = 0: set = set_value, get = get_value ## Value of the encoder
@export var rotation_offset: int = 0 ## Changes where the mid point of min and max value is located on the knob, value is in degrees
@export var min_value: int = 0
@export var max_value: int = 100
@export var sensitivity: float = 0.5
@export var angle_gap: int = 60 ## The gap in degress between [param min_value] and [param max_value] on the encoder, allowing for a visual gap between values
@export var snapping_increment: int = 10 ## Snapping distance, used when holding the control key
@export var wrap_around_value: bool = false ## If true the encoder will spin for ever, and the value will wrap to the opposite when it hits an end

var _start_mouse_pos: Vector2
var _current_rotation: int
var _value: int = value

var _gap_min: int = 0 + angle_gap
var _gap_max: int = 360 - angle_gap


## Disable process, so it is only enabled when the user is interacting with the knob
func _ready() -> void:
	
	_gap_min = 0 + angle_gap
	_gap_max = 360 - angle_gap
	
	self.set_process(false)
	($TextureRect as TextureRect).pivot_offset = size / 2
	set_value(value)


## Set the value of the Encoder, emits value_changed signal
func set_value(value: int) -> int:
	var new_value: int  = set_value_no_signal(value)
	
	value_changed.emit(new_value)
	
	return new_value


## Sets the value of the encoder, does not emit a signal
func set_value_no_signal(value: int) -> int:
	
	var new_value: int = value
	var rotation: int = 0
	
	if wrap_around_value:
		rotation = wrapi(remap(value, min_value, max_value, 0, 360), 0, 360)
		new_value = wrapi(new_value, min_value, max_value)
	else:
		rotation = clampi(remap(value, min_value, max_value, _gap_min, _gap_max), _gap_min, _gap_max)
		new_value = clampi(value, min_value, max_value)
		
	$TextureRect.rotation_degrees = rotation + rotation_offset
	$Label.text = str(new_value)
	
	_value = new_value
	return new_value


## Gets the current value of the encoder
func get_value() -> int:
	return _value


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			_start_mouse_pos = self.get_global_mouse_position()
			_current_rotation = $TextureRect.rotation_degrees - rotation_offset
			self.set_process(true)


func _process(_delta) -> void:
	var distance: Vector2 = _start_mouse_pos - self.get_global_mouse_position()
	var new_value: int = _current_rotation + ((distance.x * -1) + (distance.y * -1)) * sensitivity
	
	new_value = remap(new_value, _gap_min, _gap_max, min_value, max_value)
	
	if Input.is_key_pressed(KEY_CTRL):
		new_value = snappedi(new_value, snapping_increment)
	
	value = new_value
	
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		self.set_process(false)


func _on_texture_rect_resized() -> void:
	($TextureRect as TextureRect).pivot_offset = size / 2

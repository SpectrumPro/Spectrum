# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIColorPicker extends UIPanel
## UI Panel for showing a color wheel


## VSlider for the value input on the pad
@export var _pad_value_slider: VSlider

## The TextureRect for the Pad
@export var _pad: TextureRect

## Crosshair for the Pad
@export var _crosshair: TextureRect

## Mix Mode selection
@export var _mix_mode: OptionButton


## Hue
var _hue: float = 1

## Saturation
var _sat: float = 1

## Value
var _value: float = 1


## Time since last call
var _last_call_time: int = 0

## 45 times per second
var _call_interval: int = 1.0 / 45.0


## Updates the color
func _update_color() -> void:
	var color: Color = Color.from_hsv(_hue, _sat, _value)
	
	_update_programmer(color)


## Called when the color is changed, will only output CoreEngine.call_interval times per second to avoid overloading the server
func _update_programmer(color: Color) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0  # Convert milliseconds to seconds
	
	if current_time - _last_call_time >= _call_interval:
		Programmer.shortcut_set_color(Values.get_selection_value("selected_fixtures", []), color, _mix_mode.selected)
		
		_last_call_time = current_time


## Called for all GUI imputs on the pad
func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos: Vector2 = _pad.get_local_mouse_position().clamp(Vector2.ZERO, _pad.size)
		
		_hue = remap(mouse_pos.x, 0, _pad.size.x, 0, 1)
		_sat = remap(mouse_pos.y, _pad.size.y, 0, 0, 1)
		
		_crosshair.position = mouse_pos - _crosshair.size / 2
		_update_color()


## Called when the pad value slider is moved
func _on_pad_value_slider_value_changed(value: float) -> void:
	_value = value
	_pad.self_modulate = Color(value, value, value)
	_crosshair.modulate = Color(1-value , 1-value , 1-value)
	_update_color()


## Called when the pad is resized
func _on_pad_resized() -> void:
	_crosshair.position = Vector2(
		remap(_hue, 0, 1, 0, _pad.size.x),
		remap(_sat, 0, 1, _pad.size.y, 0)
		) - _crosshair.size / 2

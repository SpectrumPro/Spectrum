# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name TimerPicker extends PanelContainer
## UI Component to enter a time, with tap bpm button and number input


## Emitted when the value is submitted, or tap bpm is used
signal value_changed(value: float)


## The current value
var value: float: set = set_value_no_signal

## The icon of the LineEdit
var icon: Texture2D = null: set = set_icon


## List to store tap times
var _tap_times = []

## Maximum time between taps (in seconds)
const MAX_INTERVAL = 3.0


## Sets the current value
func set_value(p_value: float) -> void:
	if value != p_value:
		set_value_no_signal(p_value)
		value_changed.emit(value)


## Sets the value with out emitting value_changed
func set_value_no_signal(p_value: float) -> void:
	value = abs(p_value)
	$HBoxContainer/LineEdit.text = str(value)


## Sets the icon of the LineEdit
func set_icon(p_icon: Texture2D) -> void:
	icon = p_icon
	$HBoxContainer/LineEdit.right_icon = icon


## Called when text is sumitted in the line edit node
func _on_line_edit_text_submitted(new_text: String) -> void:
	set_value(float(new_text))


## Called when the tap button is pressed
func _on_tap_pressed() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	
	_tap_times = _tap_times.filter(func(tap_time):
		return current_time - tap_time <= MAX_INTERVAL
	)
	_tap_times.append(current_time)
	
	if _tap_times.size() > 1:
		var intervals: Array = []
		
		for i in range(1, _tap_times.size()):
			intervals.append(_tap_times[i] - _tap_times[i - 1])
		
		var avg_interval: float = Utils.sum_array(intervals) / intervals.size()
		var bpm: float = 60.0 / avg_interval
		
		set_value(snapped(60 / bpm, 0.01))


func _on_line_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				set_value(value + 0.1)
			MOUSE_BUTTON_WHEEL_DOWN:
				set_value(clamp(value - 0.1, 0, INF))
				

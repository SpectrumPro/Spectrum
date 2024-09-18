# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## Script file to control cue triggers


## The current cue
var _cue: Cue = null


## Reloads the UI elements
func _reload(reload_button: bool = true) -> void:
	if _cue:
		$HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/FrameCounter.value = _cue.timecode_trigger
		$HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/FrameCounter.editable = true
				
		$HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TcToggle.disabled = false
		if reload_button:
			$HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TcToggle.set_pressed_no_signal(_cue.timecode_enabled)
	
	else:
		$HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/FrameCounter.value = 0
		$HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/FrameCounter.editable = false
		$HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TcToggle.set_pressed_no_signal(false)
		$HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TcToggle.disabled = true



## Called when a cue is selected in the list
func _on_cue_playback_cue_selected(cue: Cue) -> void:
	_cue = cue
	_reload()


## Called when the timecode toggle switch is pressed
func _on_tc_toggle_toggled(toggled_on: bool) -> void:
	if _cue:
		_cue.set_timecode_enabled(toggled_on)
		_reload(false)


func _on_frame_counter_value_changed(value: float) -> void:
	if _cue:
		_cue.set_timecode_trigger(int(value))
		


### Called when the "Set Timecode" button is pressed to set the timecode to the current frame
#func _on_tc_now_pressed() -> void:
	#if _cue:
		#_cue.timecode_trigger[0] = $HBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/FrameCounter.value

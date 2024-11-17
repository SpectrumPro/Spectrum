# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name CueItem extends PanelContainer
## A item to represent a cue


## Emitted when this CueItem clicked
signal clicked()


## The status bar
@onready var _status_bar: ProgressBar = $VBoxContainer/ProgressBar


## The cue
var _cue: Cue = null

## The cue list
var _cue_list: CueList

## Is this cue enabled, and has its status bar visible
var _is_enabled: bool = false


## Sets the cue represented by this CueItem
func set_cue(cue: Cue, cue_list: CueList) -> void:
	if _cue_list:_cue_list.cue_changed.disconnect(_on_cue_number_changed)
	
	_cue = cue
	_cue_list = cue_list
	_cue_list.cue_changed.connect(_on_cue_number_changed)
	
	$VBoxContainer/HBoxContainer/VBoxContainer2/Name.text = cue.name
	$VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer2/HBoxContainer/CueNumber.text = str(cue.number)
	$VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer3/HBoxContainer/FadeTime.text = str(cue.fade_time)
	$VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer4/HBoxContainer/PreWait.text = str(cue.pre_wait)
	
	match cue.trigger_mode:
		Cue.TRIGGER_MODE.MANUAL: $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer/VBoxContainer/Manual.show()
		Cue.TRIGGER_MODE.AFTER_LAST: $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer/VBoxContainer/AfterLast.show()
		Cue.TRIGGER_MODE.WITH_LAST: $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer/VBoxContainer/WithLast.show()


## Shows or hides the status bar
func set_status_bar(state: bool, time: float) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_method(_status_bar.set_value_no_signal, _status_bar.value, 1 if state else 0, time)


## Called when the CueList cue number changes
func _on_cue_number_changed(cue_number: float) -> void:
	if cue_number == _cue.number:
		_is_enabled = true
		set_status_bar(true, _cue.fade_time)
	
	elif _is_enabled: 
		var fade_time: float = 0
		if cue_number in _cue_list.cues:
			fade_time = _cue_list.cues[cue_number].fade_time
		else:
			fade_time = _cue.fade_time
		
		_is_enabled = false
		set_status_bar(false, fade_time)


## Called when an input event is decected in the panel
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		
		if event.double_click: 
			if _cue_list and _cue:
				_cue_list.seek_to(_cue.number)
			
		else:
			clicked.emit()

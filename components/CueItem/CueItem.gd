# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name CueItem extends PanelContainer
## A item to represent a cue


## Emitted when this CueItem clicked
signal clicked()


## The cue
var _cue: Cue = null

## The cue list
var _cue_list: CueList


## Sets the cue represented by this CueItem
func set_cue(cue: Cue, cue_list: CueList) -> void:
	_cue = cue
	_cue_list = cue_list
	$VBoxContainer/HBoxContainer/VBoxContainer2/Name.text = cue.name
	$VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer2/HBoxContainer/CueNumber.text = str(cue.number)
	$VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer3/HBoxContainer/FadeTime.text = str(cue.fade_time)
	$VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer4/HBoxContainer/PreWait.text = str(cue.pre_wait)
	
	match cue.trigger_mode:
		Cue.TRIGGER_MODE.MANUAL: $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer/VBoxContainer/Manual.show()
		Cue.TRIGGER_MODE.AFTER_LAST: $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer/VBoxContainer/AfterLast.show()
		Cue.TRIGGER_MODE.WITH_LAST: $VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/PanelContainer/VBoxContainer/WithLast.show()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		
		if event.double_click: 
			if _cue_list and _cue:
				_cue_list.seek_to(_cue.number)
			
		else:
			clicked.emit()

# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name ConfirmationBox extends DialogBox
## A Confirmation Box


## Container that stores all the modes
@export var _mode_container: HBoxContainer = null


## Display mode to change what buttons are shown
enum DisplayMode {Default, Delete, Info}

## Deafult titles to match with the display mode
var _default_titles: Array = [
	"Confirm Action",
	"Are you sure want to delete this? This can not be undone!",
	"Info"
]


## Sets the display mode
func set_mode(mode: DisplayMode) -> void:
	for hbox: HBoxContainer in _mode_container.get_children():
		if hbox.get_index() == mode:
			hbox.show()
		else:
			hbox.hide()
	
	set_title(_default_titles[mode])


## Called when a rejected button is pressed, ie cancel or go back
func _on_confirmed_button_pressed() -> void:
	_promise.resolve()


## Called when a rejected button is pressed, ie cancel or go back
func _on_rejected_button_pressed() -> void:
	_promise.reject()

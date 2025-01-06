# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name NameDialogBox extends DialogBox
## A Confirmation Box


## The line edit node
@export var _line_edit: LineEdit = null


func _ready() -> void:
	_line_edit.grab_focus.call_deferred()


## Changes the text in the label
func set_text(text: String) -> void:
	_line_edit.text = text


## Called when a rejected button is pressed, ie cancel or go back
func _on_confirmed_button_pressed() -> void:
	confirmed.emit(_line_edit.text)


## Called when a rejected button is pressed, ie cancel or go back
func _on_rejected_button_pressed() -> void:
	rejected.emit()

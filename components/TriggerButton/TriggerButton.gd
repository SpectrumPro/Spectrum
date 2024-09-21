# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends Button
## Ui button to trigger an action on click

## Emitted when this button is right clicked
signal right_clicked(from: Button)

## Stored here so the indicator can be resized
var _percentage: float = 0

## Sets the text of this button, 
## use this instead of buttons built in set_text methord, as this label supports text wrapping
func set_label_text(label_text: String) -> void:
	$Label.text = label_text


## Sets the indicator value of this button
func set_value(percentage: float) -> void:
	_percentage = percentage
	$Value.set_deferred("size", Vector2(remap(percentage, 0, 1, 0, size.x), size.y))



func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 2:
			right_clicked.emit(self)


func _on_resized() -> void:
	set_value(_percentage)

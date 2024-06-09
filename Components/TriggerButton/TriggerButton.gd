# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Button
## Ui button to trigger an action on click

signal right_clicked(from: Button)


func set_label_text(label_text: String) -> void:
	## Sets the text of this button, 
	## use this instead of buttons built in set_text methord, as this label supports text wrapping
	
	$Label.text = label_text


func set_value(percentage: float) -> void:
	$ProgressBar.value = percentage


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 2:
			right_clicked.emit(self)

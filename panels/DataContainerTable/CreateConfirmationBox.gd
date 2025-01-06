# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name zsdvcf extends PanelContainer
## Panel for a CreateConfirmationBox


## Emitted when the confirm button is pressed
signal confirmed()


## The button group for the mode buttons
var button_group: ButtonGroup = ButtonGroup.new()


func _ready() -> void:
	Values.connect_to_selection_value("selected_fixtures", func (fixtures: Array) -> void:
		$VBoxContainer2/ActionText/NumOfFixtures.text = str(len(fixtures))
	)
	
	for button: Button in $VBoxContainer2/SaveModes.get_children():
		button.button_group = button_group


## Called when the cancel button is pressed
func _on_cancel_pressed() -> void: hide()

## Called when the create button is pressed
func _on_create_confirmation_pressed() -> void: confirmed.emit()

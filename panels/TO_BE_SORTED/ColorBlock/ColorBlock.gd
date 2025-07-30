# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name ColorBlockPanel extends UIPanel
## A Color Block


## Removes the settings node and makes sure its visible
func _ready() -> void:
	remove_child(settings_node)
	settings_node.show()


## Called when the color picker button is changed, then updates the color
func _on_color_picker_color_changed(p_color: Color) -> void:
	self.color = p_color


## Saves the current settings of this panel to a Dictionary
func save() -> Dictionary:
	return {
		"color": var_to_str(self.color)
	}


## Loads the settings of this panel from a Dictionary
func load(save_data: Dictionary) -> void:
	var saved_color: Variant = str_to_var(save_data.get("color"))
	
	if saved_color is Color:
		self.color = saved_color

# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name PanelPicker extends PanelContainer
## Picks panel items for the Desk


## Emitted when a panel is chosen
signal panel_chosen(panel: PackedScene)

## Emitted when the cancel button is pressed
signal cancel_pressed()


func _ready() -> void:
	for panel_name: String in Interface.panels.keys():
		var panel_item: PanelPickerItem = load("res://components/PanelPickerItem/PanelPickerItem.tscn").instantiate()
		
		panel_item.set_title(panel_name.capitalize())
		panel_item.set_info(panel_name)
		
		panel_item.set_icon(Interface.panel_icons.get(panel_name, Texture2D.new()))
		
		panel_item.pressed.connect(func () -> void:
			panel_chosen.emit(Interface.panels[panel_name])
		)
		
		$VBoxContainer/PanelContainer2/ScrollContainer/GridContainer.add_child(panel_item)


func _on_grid_container_resized() -> void:
	$VBoxContainer/PanelContainer2/ScrollContainer/GridContainer.columns = clamp(int($VBoxContainer/PanelContainer2/ScrollContainer.size.x / 400), 1, INF)


func _on_button_pressed() -> void:
	cancel_pressed.emit()

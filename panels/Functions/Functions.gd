# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIFunctions extends UIPanel
## UI panel for managing functions


## The Delete button
@export var _delete_button: Button

## The ComponentList
@export var _component_list: ComponentList



func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		print(var_to_str(event))
		print("Shortcut:", var_to_str($VBoxContainer/HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/Create.shortcut.events[0]))


## Called when the Create button is pressed
func _on_create_pressed() -> void:
	Interface.show_create_component(CreateComponent.Mode.Component, "Function", true)


## Called when the Delete button is pressed
func _on_delete_pressed() -> void:
	Interface.confirm_and_delete_component(_component_list.get_selected())


## Called when an item is selected
func _on_component_list_selected(component: EngineComponent) -> void:
	_delete_button.disabled = component == null

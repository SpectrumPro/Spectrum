# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIFunctions extends UIPanel
## UI panel for managing functions


## The Delete button
@export var _delete_button: Button

## The Duplicate Button
@export var _duplicate_button: Button

## The ComponentList
@export var _component_list: ComponentList


## Init
func _init() -> void:
	super._init()
	_set_class_name("UIFunctions")


## Called when the Create button is pressed
func _on_create_pressed() -> void:
	Interface.show_create_component(CreateComponent.Mode.Component, "Function", true)


## Called when the Delete button is pressed
func _on_delete_pressed() -> void:
	Interface.confirm_and_delete_component(_component_list.get_selected())


## Called when the Duplicate button is pressed
func _on_duplicate_pressed() -> void:
	Core.duplicate_component(_component_list.get_selected()).then(func (component: EngineComponent):
		if component:
			Interface.show_name_prompt(component)
	)


## Called when an item is selected
func _on_component_list_selected(component: EngineComponent) -> void:
	_delete_button.disabled = component == null
	_duplicate_button.disabled = component == null

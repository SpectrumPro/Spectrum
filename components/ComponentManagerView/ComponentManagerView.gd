# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name ComponentManagerView extends UIComponent
## ComponentManagerView


## The EngineComponent classname to use
@export var classname: String

## Table columns made up of SettingsManager
@export var table_column_names: Array[String]

## Nodes group
@export_group("Nodes")

## The SettingsManagerMultiView
@export var settings_manager_multi_view: SettingsManagerMultiView

## The NewComponent Button
@export var new_button: Button

## The DeleteComponent Button
@export var delete_button: Button

## The DuplicateComponent Button
@export var duplicate_button: Button


## init
func _init() -> void:
	super._init()
	
	_set_class_name("ComponentManagerView")


## Ready
func _ready() -> void:
	settings_manager_multi_view.reset()
	settings_manager_multi_view.table_column_names = table_column_names
	settings_manager_multi_view._ready()
	
	ComponentDB.request_class_callback(classname, _class_callback)
	
	settings_manager_multi_view.manager_selected.connect(_on_manager_selected)
	new_button.pressed.connect(_on_new_button_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)
	duplicate_button.pressed.connect(_on_duplicate_button_pressed)
	
	delete_button.set_disabled(true)
	duplicate_button.set_disabled(true)
	
	_class_callback(ComponentDB.get_components_by_classname(classname), [])


## Called each time a Universe is added or removed from ComponentDB
func _class_callback(p_added: Array, p_removed: Array) -> void:
	for component: EngineComponent in p_added:
		settings_manager_multi_view.add_manager(component.settings())
	
	for component: EngineComponent in p_removed:
		settings_manager_multi_view.remove_manager(component.settings())


## Called when a SettingsManager is selected
func _on_manager_selected(p_manager: SettingsManager) -> void:
	var state: bool = is_instance_valid(p_manager)
	
	delete_button.set_disabled(not state)
	duplicate_button.set_disabled(not state)


## Called when the NewComponent Button is pressed
func _on_new_button_pressed() -> void:
	Core.create_component(classname).then(func (p_component: EngineComponent):
		if not is_instance_valid(p_component):
			return
		
		Interface.prompt_settings_module(self, p_component.settings().get_entry("name"))
	)


## Called when the DeleteComponent Button is presse
func _on_delete_button_pressed() -> void:
	settings_manager_multi_view.get_selected_manager().get_owner().delete()


## Called when the DuplicateComponent Button is pressed
func _on_duplicate_button_pressed() -> void:
	Core.duplicate_component(settings_manager_multi_view.get_selected_manager().get_owner())

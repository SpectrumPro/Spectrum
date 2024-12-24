# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIFunctions extends UIPanel
## UI panel for managing functions


## The ItemListView used to store the functions
@onready var item_list_view: ItemListView = $ItemListView

## The settings container
@onready var _popup_container: SettingsContainer = $SettingsContainer


func _ready() -> void:
	## Connect to function signals
	ComponentDB.request_class_callback("Function", _update_list)
	
	## Connect to selection signals
	Interface.add_root_child(_popup_container)
	
	_update_list(ComponentDB.get_components_by_classname("Function"))


## Reload the list of fixtures
func _update_list(added: Array = [], removed: Array = []) -> void:
	if removed:
		item_list_view.remove_items(removed)
	
	for function: Function in added:
		if function is not Cue:
			item_list_view.add_item(function, [["fade_in_speed", "set_fade_in_speed", "fade_in_speed_changed"], ["fade_out_speed", "set_fade_out_speed", "fade_out_speed_changed"]], "set_name", "name_changed")


## Called when the delete button is pressed on the ItemListView
func _on_item_list_view_delete_requested(items: Array) -> void:
	for function: Function in items:
		function.delete()


## Called when the selection has changed
func _on_item_list_view_selection_changed(items: Array) -> void:
	item_list_view.set_selected(items)


func _on_item_list_view_edit_requested(items: Array) -> void:
	if not items:
		return
	
	var settings_panel: Control = null
	var component: EngineComponent = items[0]
	
	
	if Interface.component_settings_panels.get(component.self_class_name):
		var config: Dictionary = Interface.component_settings_panels[component.self_class_name]
		
		settings_panel = config.panel.instantiate()
		settings_panel.get(config.method).call_deferred(component)
		
		_popup_container.set_node(settings_panel)
	
	_popup_container.show()


func _on_item_list_view_add_requested() -> void:
	$CreateFunction.show()


func _on_create_function_component_added(component: EngineComponent) -> void:
	$ComponentNamePopup.set_component(component)
	$ComponentNamePopup.show()
	$ComponentNamePopup.focus()

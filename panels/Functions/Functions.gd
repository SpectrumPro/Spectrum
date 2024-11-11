# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends Control
## UI panel for managing functions


## The ItemListView used to store the functions
@onready var item_list_view: ItemListView = $ItemListView

## The settings container
@onready var _popup_container: SettingsContainer = $SettingsContainer


func _ready() -> void:
	## Connect to function signals
	Core.functions_added.connect(self._reload_functions)
	Core.functions_removed.connect(self._reload_functions)
	
	remove_child(_popup_container)
	Interface.add_root_child(_popup_container)
	
	_reload_functions()


## Reload the list of functions
func _reload_functions(arg1=null, arg2=null) -> void:
	item_list_view.remove_all()
	item_list_view.add_items(Core.functions.values(), [["fade_in_speed", "set_fade_in_speed", "fade_in_speed_changed"], ["fade_out_speed", "set_fade_out_speed", "fade_out_speed_changed"]], "set_name", "name_changed")


## Called when the delete button is pressed on the ItemListView
func _on_item_list_view_delete_requested(items: Array) -> void:
	Core.remove_functions(items)


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

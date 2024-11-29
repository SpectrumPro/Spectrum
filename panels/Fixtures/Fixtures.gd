# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends Control
## UI panel for managing fixtures


## The ItemListView used to store the fixtures
@onready var item_list_view: ItemListView = $ItemListView


func _ready() -> void:
	## Connect to fixture signals
	ComponentDB.request_class_callback("Fixture", _update_list)
	
	## Connect to selection signals
	Values.connect_to_selection_value("selected_fixtures", item_list_view.set_selected)
	
	_update_list(ComponentDB.get_components_by_classname("Fixture"))


## Reload the list of fixtures
func _update_list(added: Array = [], removed: Array = []) -> void:
	if removed:
		item_list_view.remove_items(removed)
	
	if added:
		item_list_view.add_items(added, [["channel", "set_channel", "channel_changed"]], "set_name", "name_changed")


## Called when the delete button is pressed on the ItemListView
func _on_item_list_view_delete_requested(items: Array) -> void:
	for fixture: Fixture in items:
		fixture.delete()


## Called when fixtures are selected in the list
func _on_item_list_view_selection_changed(items: Array) -> void:
	Values.set_selection_value("selected_fixtures", items)

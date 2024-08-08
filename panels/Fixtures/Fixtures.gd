# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## UI panel for managing fixtures


## The ItemListView used to store the fixtures
@onready var item_list_view: ItemListView = $ItemListView


func _ready() -> void:
	## Connect to fixture signals
	Core.fixtures_added.connect(self._reload_fixtures)
	Core.fixtures_removed.connect(self._reload_fixtures)
	
	## Connect to universe signals
	Core.universes_added.connect(self._reload_fixtures)
	Core.universes_removed.connect(self._reload_fixtures)
	
	## Connect to selection signals
	Values.connect_to_selection_value("selected_fixtures", item_list_view.set_selected)
	
	_reload_fixtures()


## Reload the list of fixtures
func _reload_fixtures(arg1=null, arg2=null) -> void:
	item_list_view.remove_all()
	item_list_view.add_items(Core.fixtures.values(), [["channel", "set_channel"]], "set_name", "name_changed")


## Called when the delete button is pressed on the ItemListView
func _on_item_list_view_delete_requested(items: Array) -> void:
	for fixture: Fixture in items:
		fixture.delete()


## Called when fixtures are selected in the list
func _on_item_list_view_selection_changed(items: Array) -> void:
	Values.set_selection_value("selected_fixtures", items)

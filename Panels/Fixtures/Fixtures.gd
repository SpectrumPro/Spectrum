# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## GUI element for managing fixtures

@export var item_list_view: NodePath


func _ready() -> void:
	Core.fixtures_added.connect(self._reload_fixtures)
	Core.fixtures_removed.connect(self._reload_fixtures)
	Core.universes_added.connect(self._reload_fixtures)
	Core.universes_removed.connect(self._reload_fixtures)
	Values.connect_to_selection_value("selected_fixtures", self._reload_fixtures)


func _reload_fixtures(_fixture=null) -> void:
	## Reload the list of fixtures
	
	self.get_node(item_list_view).remove_all()
	self.get_node(item_list_view).add_items(Core.fixtures.values())


func _on_item_list_view_delete_requested(items: Array) -> void:
	## Called when the delete button is pressed on the ItemListView
	
	for fixture: Fixture in items:
		fixture.universe.remove_fixture(fixture)


func _on_item_list_view_add_requested() -> void:
	Interface.open_panel_in_window("add_fixture")


func _on_item_list_view_selection_changed(items: Array) -> void:
	Core.set_fixture_selection(items)

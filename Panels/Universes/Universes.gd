# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## GUI element for managing universes

@export var item_list_view: NodePath

func _ready() -> void:
	Core.universes_added.connect(self._reload_universes)
	Core.universes_removed.connect(self._reload_universes)
	Core.universe_name_changed.connect(self._reload_universes)
	
	Values.connect_to_selection_value("selected_universes", self._on_selection_changed)


func _reload_universes(_universes=null) -> void:
	## Reload the list of fixtures
	
	self.get_node(item_list_view).remove_all()
	self.get_node(item_list_view).add_items(Core.universes.values())
	self.get_node(item_list_view).set_selected(Values.get_selection_value("selected_universes", []))
	


func _on_item_list_view_delete_requested(items: Array) -> void:
	## Called when the delete button is pressed on the ItemListView
	Core.remove_universes(Values.get_selection_value("selected_universes"))
	Values.set_selection_value("selected_universes", [])


func _on_item_list_view_add_requested() -> void:
	Core.new_universe()


func _on_selection_changed(items: Array) -> void:
	self.get_node(item_list_view).set_selected(items)


func _on_item_list_view_selection_changed(items: Array) -> void:
	Values.set_selection_value("selected_universes", items)
	self.get_node(item_list_view).set_selected(items)

# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## GUI element for managing universes


## The ItemListView used to store the universes
@onready var item_list_view: ItemListView = $ItemListView


func _ready() -> void:
	## Connect to universe signals
	Core.universes_added.connect(self._reload_universes)
	Core.universes_removed.connect(self._reload_universes)
	
	_reload_universes()


## Reload the list of universes
func _reload_universes(arg1=null, arg2=null) -> void:
	item_list_view.remove_all()
	item_list_view.add_items(Core.universes.values(), [], "set_name")


## Called when the delete button is pressed on the ItemListView
func _on_item_list_view_delete_requested(items: Array) -> void:
	Core.remove_universes(items)


## Called when the add button is pressed
func _on_item_list_view_add_requested() -> void:
	Core.add_universe()


## Called when the selection is changed
func _on_item_list_view_selection_changed(items: Array) -> void:
	item_list_view.set_selected(items)

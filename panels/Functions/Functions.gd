# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## UI panel for managing functions


## The ItemListView used to store the functions
@onready var item_list_view: ItemListView = $ItemListView


func _ready() -> void:
	## Connect to function signals
	Core.functions_added.connect(self._reload_functions)
	Core.functions_removed.connect(self._reload_functions)
	
	_reload_functions()


## Reload the list of functions
func _reload_functions(arg1=null, arg2=null) -> void:
	item_list_view.remove_all()
	item_list_view.add_items(Core.functions.values(), [["fade_in_speed", "set_fade_in_speed"], ["fade_out_speed", "set_fade_out_speed"]], "set_name", "name_changed")


## Called when the delete button is pressed on the ItemListView
func _on_item_list_view_delete_requested(items: Array) -> void:
	Core.remove_functions(items)


## Called when the selection has changed
func _on_item_list_view_selection_changed(items: Array) -> void:
	item_list_view.set_selected(items)

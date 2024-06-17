# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## UI panel for managing functions

@export var item_list_view: NodePath


func _ready() -> void:
	Core.functions_added.connect(self._reload_functions)
	Core.functions_removed.connect(self._reload_functions)
	Core.function_name_changed.connect(self._reload_functions)
	
	_reload_functions()


## Reload the list of functions
func _reload_functions(arg1=null, arg2=null) -> void:
	
	self.get_node(item_list_view).remove_all()
	self.get_node(item_list_view).add_items(Core.functions.values(), [["fade_in_speed", "set_fade_in_speed"], ["fade_out_speed", "set_fade_out_speed"]], "set_name")
	


## Called when the delete button is pressed on the ItemListView
func _on_item_list_view_delete_requested(items: Array) -> void:
	
	Core.remove_functions(items)
	


func _on_item_list_view_selection_changed(items: Array) -> void:
	self.get_node(item_list_view).set_selected(items)

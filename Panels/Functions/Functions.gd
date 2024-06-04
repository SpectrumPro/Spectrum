# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## GUI element for managing functions

@export var item_list_view: NodePath


func _ready() -> void:
	Core.scenes_added.connect(self._reload_functions)
	Core.scenes_removed.connect(self._reload_functions)
	Core.scene_name_changed.connect(self._reload_functions)
	
	_reload_functions()


func _reload_functions(arg1=null, arg2=null) -> void:
	## Reload the list of fixtures
	
	self.get_node(item_list_view).remove_all()
	self.get_node(item_list_view).add_items(Core.scenes.values(), [["fade_in_speed", "set_fade_in_speed"], ["fade_out_speed", "set_fade_out_speed"]], "set_name")
	


func _on_item_list_view_delete_requested(items: Array) -> void:
	## Called when the delete button is pressed on the ItemListView
	
	Core.remove_scenes(items)
	


func _on_item_list_view_selection_changed(items: Array) -> void:
	self.get_node(item_list_view).set_selected(items)

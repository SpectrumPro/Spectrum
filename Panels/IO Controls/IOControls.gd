# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## GUI element for managing universe io devices

@export var item_list_view: NodePath

var current_universe: Universe

func _ready() -> void:
	Core.universe_selection_changed.connect(self._reload_universes)

func _reload_universes(selected_universes: Array[Universe] = [current_universe]) -> void:
	
	## Check if mutiple universes (or none) are selected, if so dont update the output list, only clear it
	if len(selected_universes) == 1:
		current_universe = selected_universes[0]
		
		current_universe.outputs_added.connect(self._reload_io)
		current_universe.outputs_removed.connect(self._reload_io)
		
		self.get_node(item_list_view).buttons_enabled = true
		
	else:
		if current_universe:
			current_universe.outputs_added.disconnect(self._reload_io)
			current_universe.outputs_removed.disconnect(self._reload_io)
		
		current_universe = null
		self.get_node(item_list_view).buttons_enabled = false
	
	_reload_io()

func _reload_io(_io=null) -> void:
	## Reloads the list of io devices
	
	self.get_node(item_list_view).remove_all()
	
	if current_universe:
		self.get_node(item_list_view).add_items(current_universe.outputs.values())


func _on_item_list_view_delete_requested(items: Array) -> void:
	## Called when the delete button is pressed on the ItemListView
	
	current_universe.remove_outputs(items)


func _on_item_list_view_add_requested() -> void:
	current_universe.new_output()


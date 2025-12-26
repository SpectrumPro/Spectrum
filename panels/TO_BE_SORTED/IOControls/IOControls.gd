# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

extends Control
## UI panel for managing universe io devices

@export var item_list_view: NodePath

var current_universe: Universe

func _ready() -> void:
	Values.connect_to_selection_value("selected_universes", self._reload_universes)
	_reload_universes(Values.get_selection_value("selected_universes", []))


func _reload_universes(selected_universes: Array) -> void:
	 
	print("reloading io list, with: ", selected_universes)
	# Check if mutiple universes (or none) are selected, if so dont update the output list, only clear it
	if len(selected_universes) == 1:
		
		if current_universe:
			_dissconnect()
		
		current_universe = selected_universes[0]
		
		current_universe.outputs_added.connect(self._reload_io)
		current_universe.outputs_removed.connect(self._reload_io)
		
		self.get_node(item_list_view).buttons_enabled = true
		
	else:
		if current_universe:
			_dissconnect()
		
		current_universe = null
		self.get_node(item_list_view).buttons_enabled = false
	
	_reload_io()


func  _dissconnect() -> void:
	current_universe.outputs_added.disconnect(self._reload_io)
	current_universe.outputs_removed.disconnect(self._reload_io)


## Reloads the list of io devices
func _reload_io(_io=null) -> void:
	
	self.get_node(item_list_view).remove_all()
	
	if current_universe:
		self.get_node(item_list_view).add_items(current_universe.outputs.values())


## Called when the delete button is pressed on the ItemListView
func _on_item_list_view_delete_requested(items: Array) -> void:
	
	current_universe.remove_outputs(items)


func _on_item_list_view_add_requested() -> void:
	current_universe.add_output(ArtNetOutput.new())


func _on_item_list_view_selection_changed(items: Array) -> void:
	self.get_node(item_list_view).set_selected(items)

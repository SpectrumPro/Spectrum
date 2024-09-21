# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends Control
## GUI element for managing universes


## The ItemListView used to store the universes
@onready var universe_list: ItemListView = $HSplitContainer/UniverseList

## The ItemListView used to store the io plugins
@onready var io_list: ItemListView =  $HSplitContainer/IOList

## The currentley selected universe displayed in the edit panel
var _current_universe: Universe = null


func _ready() -> void:
	## Connect to universe signals
	Core.universes_added.connect(self._reload_universes)
	Core.universes_removed.connect(self._reload_universes)
	
	_reload_universes()


## Reload the list of universes
func _reload_universes(arg1=null, arg2=null) -> void:
	universe_list.remove_all()
	universe_list.add_items(Core.universes.values(), [], "set_name", "name_changed")


func _reload_io(arg1=null) -> void:
	io_list.remove_all()
	
	if _current_universe:
		io_list.add_items(_current_universe.outputs.values(), [], "set_name", "name_changed")
		io_list.set_buttons_enabled(true)
	else:
		io_list.set_buttons_enabled(false)



## Called when the delete button is pressed on the ItemListView
func _on_universe_list_delete_requested(items: Array) -> void:
	Core.remove_universes(items)
	if _current_universe in items:
		_current_universe.outputs_added.disconnect(_reload_io)
		_current_universe.outputs_removed.disconnect(_reload_io)
		
		_current_universe = null
		_reload_io()

## Called when the add button is pressed
func _on_universe_list_add_requested() -> void:
	Core.add_universe()


## Called when the selection is changed
func _on_universe_list_selection_changed(items: Array) -> void:
	universe_list.set_selected(items)
	
	if _current_universe:
		_current_universe.outputs_added.disconnect(_reload_io)
		_current_universe.outputs_removed.disconnect(_reload_io)
	
	if len(items) == 1:
		_current_universe = items[0]
		_current_universe.outputs_added.connect(_reload_io)
		_current_universe.outputs_removed.connect(_reload_io)
	
	else:
		_current_universe = null
	
	_reload_io()


func _on_io_list_add_requested() -> void:
	if _current_universe:
		_current_universe.add_output(ArtNetOutput.new())


func _on_io_list_delete_requested(items: Array) -> void:
	if _current_universe:
		_current_universe.remove_outputs(items)


func _on_io_list_selection_changed(items: Array) -> void:
	io_list.set_selected(items)

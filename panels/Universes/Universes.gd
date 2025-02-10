# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIUniverses extends UIPanel
## GUI element for managing universes


## The ItemList for showing all universe outputs
@export var _output_list: ItemList = null

## The RemoveOutput button
@export var _remove_output: Button = null


## The current selected universe
var _universe: Universe = null

## All signals that need to be connected / disconnected from the universe
var _universe_signal_connections: Dictionary = {
	"outputs_added": _add_outputs,
	"outputs_removed": _remove_outputs
}

var _output_signal_connections: Dictionary = {
	"name_changed": _on_output_name_changed
}

## RefMap for DMXOutput:ItemList_idx
var _output_map: RefMap = RefMap.new()


## Sets the current universe
func set_universe(universe: Universe) -> void:
	Utils.disconnect_signals(_universe_signal_connections, _universe)
	_universe = universe
	Utils.connect_signals(_universe_signal_connections, _universe)
	
	_add_outputs(_universe.get_outputs().values())


## Called when outputs are added to the universe
func _add_outputs(outputs: Array) -> void:
	for output: DMXOutput in outputs:
		_output_map.map(output, _output_list.add_item(output.name, Interface.get_class_icon(output.self_class_name)))
		Utils.connect_signals_with_bind(_output_signal_connections, output)


## Called when outputs are removed from the universe
func _remove_outputs(outputs: Array) -> void:
	for output: DMXOutput in outputs:
		_output_list.remove_item(_output_map.left(output))
		_output_map.erase_left(output)
		Utils.disconnect_signals_with_bind(_output_signal_connections, output)


## Called when an output is renamed
func _on_output_name_changed(new_name: String, output: DMXOutput) -> void:
	_output_list.set_item_text(_output_map.left(output), new_name)


## Called when the NewOutput button is pressed
func _on_new_output_pressed() -> void:
	Interface.show_create_component(CreateComponent.Mode.Class, "DMXOutput").then(func (classname: String):
		_universe.create_output(classname)
	)


## Called when the RemoveOutput button is pressed
func _on_remove_output_pressed() -> void:
	for idx: int in _output_list.get_selected_items():
		_output_map.right(idx).delete()


## Called when an item is selected in the OutputList
func _on_outputs_list_multi_selected(index: int, selected: bool) -> void:
	_remove_output.disabled = not _output_list.is_anything_selected()


## Called when nothing is clicked in the OutputList
func _on_outputs_list_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	_remove_output.disabled = true
	_output_list.deselect_all()

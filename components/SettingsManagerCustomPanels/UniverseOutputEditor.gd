# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UniverseOutputEditor extends PanelContainer
## Editor for universe outputs


## The ComponentManagerView
@export var component_manager_view: ComponentManagerView


## The universe to edit
var _universe: Universe

## SignalGroup for Universes
var _signal_group: SignalGroup = SignalGroup.new([
	_on_outputs_added,
	_on_outputs_removed,
])


## Sets the universe
func set_universe(p_universe: Universe) -> void:
	_signal_group.disconnect_object(_universe)
	_universe = p_universe
	_signal_group.connect_object(_universe)
	
	component_manager_view.reset()
	component_manager_view.class_callback(_universe.get_outputs().values(), [])


## Called when outputs are added to the selected universe
func _on_outputs_added(p_outputs: Array[DMXOutput]) -> void:
	component_manager_view.class_callback(p_outputs, [])


## Called when outputs are removed from the selected universe
func _on_outputs_removed(p_outputs: Array[DMXOutput]):
	component_manager_view.class_callback([], p_outputs)


## Called when the create button is pressed in the ComponentManagerView
func _on_component_manager_view_create_requested(p_classname: String) -> void:
	_universe.create_output(p_classname)


## Called when the duplicate button is pressed in the ComponentManagerView
func _on_component_manager_view_duplicate_requested(p_component: EngineComponent) -> void:
	Core.duplicate_component(p_component).then(func (p_new_component: EngineComponent):
		_universe.add_output(p_new_component)
	)

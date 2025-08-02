# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UIControlMethodPicker extends UIPanel
## Picker for control methods


## Emitted when a method is chosen
signal method_chosen(control_name: String)


## List of controls for the trigger
@export var _list: ItemList


## Component to show
var _component: EngineComponent

## All controls on the component
var _controls: Dictionary[String, Dictionary]


## Sets the component
func set_component(component: EngineComponent) -> void:
	_list.clear()
	_list.add_item("None")
	_list.select(0)
	
	_component = component
	_controls = _component.get_control_methods()
	
	for control_name: String in _controls:
		_list.add_item(control_name)


## Confirms the current selection
func _confirm_selection() -> void:
	var selected: int = _list.get_selected_items()[0]
	var control_name: String = _controls.keys()[selected - 1] if selected else ""
	
	method_chosen.emit(control_name)


## Called when the confirm button is pressed
func _on_confirm_pressed() -> void:
	_confirm_selection()


## Called when an item is dubble clicked in the tree
func _on_list_item_activated(index: int) -> void:
	_confirm_selection()

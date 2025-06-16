# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIControlMethodPicker extends UIPanel
## Picker for control methods


## Emitted when a method is chosen
signal method_chosen(up_method: String, down_method: String)


## List of controls for the UP trigger
@export var _up_list: ItemList

## List of control for the DOWN trigger
@export var _down_list: ItemList


## Component to show
var _component: EngineComponent

## All controls on the component
var _controls: Dictionary[String, Dictionary]


## Sets the component
func set_component(component: EngineComponent) -> void:
	_up_list.clear()
	_down_list.clear()
	
	_up_list.add_item("None")
	_down_list.add_item("None")
	
	_up_list.select(0)
	_down_list.select(0)
	
	_component = component
	_controls = _component.get_control_methods()
	
	for method_name: String in _controls:
		method_name = method_name.capitalize()
		_up_list.add_item(method_name)
		_down_list.add_item(method_name)


## Called when the confirm button is pressed
func _on_confirm_pressed() -> void:
	var up_selected: int = _up_list.get_selected_items()[0]
	var up_method: String = _controls.keys()[up_selected - 1] if up_selected else ""
	
	var down_selected: int = _down_list.get_selected_items()[0]
	var down_method: String = _controls.keys()[down_selected - 1] if down_selected else ""
	
	method_chosen.emit(up_method, down_method)

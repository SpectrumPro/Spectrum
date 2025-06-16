# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name ComponentTrigger extends RefCounted
## Triggers when inputs are recieved


## Component for all action
var _component: EngineComponent

## The callable for the UP action
var _up_method: Callable

## The args for the UP action
var _up_args: Array[Variant]

## The callable for the DOWN action
var _down_method: Callable

## The args for the DOWN action
var _down_args: Array[Variant]

## The callable for the VALUE action
var _value_method: Callable


## Calls the UP action
func up() -> void:
	if _up_method.is_valid():
		_up_method.callv(_up_args)


## Calls the DOWN action
func down() -> void:
	if _down_method.is_valid():
		_down_method.callv(_down_args)


## Calls the VALUE action
func value(p_value: Variant) -> void:
	if _value_method.is_valid():
		_value_method.callv(p_value)


## Sets the Component
func set_component(p_component: EngineComponent) -> void:
	reset()
	
	_component = p_component


## Sets the UP method
func set_up_method(p_method_name: String) -> void:
	if not _component:
		return
	
	_up_method = _component.get_control_method(p_method_name).get("method", Callable())


## Sets the UP args
func set_up_args(args: Array[Variant]) -> void:
	_up_args = args


## Sets the UP method
func set_down_method(p_method_name: String) -> void:
	if not _component:
		return
	
	_down_method = _component.get_control_method(p_method_name).get("method", Callable())


## Sets the DOWN args
func set_down_args(args: Array[Variant]) -> void:
	_down_args = args


## Sets the VALUE method
func set_value_method(p_method_name: String) -> void:
	if not _component:
		return
	
	_value_method = _component.get_control_method(p_method_name).get("method", Callable())


## Resets this ComponentTrigger
func reset() -> void:
	_up_method = Callable()
	_up_args.clear()
	
	_down_method = Callable()
	_down_args.clear()
	
	_component = null
	_value_method = Callable()


## Saves this ComponentTrigger into a dictionary
func seralize() -> Dictionary:
	var seralized_data: Dictionary = {
		"component": _component.uuid,
	}
	
	if _up_method.is_valid():
		seralized_data["up_method"] = _up_method.get_method()
		seralized_data["up_args"] = var_to_str(_up_args)
		
	if _down_method.is_valid():
		seralized_data["down_method"] = _down_method.get_method()
		seralized_data["down_args"] = var_to_str(_down_args)
	
	if _value_method.is_valid():
		seralized_data["value_method"] = _value_method.get_method()
	
	return seralized_data


## Loads this ComponentTrigger from a dictionary
func deseralize(seralized_data: Dictionary) -> ComponentTrigger:
	var component_uuid: String = type_convert(seralized_data.get("component", ""), TYPE_STRING)
	ComponentDB.request_component(component_uuid, func (component: EngineComponent):
		set_component(component)
		set_value_method(type_convert(seralized_data.get("value_method", ""), TYPE_STRING))
		
		set_up_method(type_convert(seralized_data.get("up_method", ""), TYPE_STRING))
		set_up_args(type_convert(str_to_var(seralized_data.get("up_args", "")), TYPE_ARRAY))
		
		set_down_method(type_convert(seralized_data.get("down_method", ""), TYPE_STRING))
		set_down_args(type_convert(str_to_var(seralized_data.get("down_args", "")), TYPE_ARRAY))
	)
	
	return self

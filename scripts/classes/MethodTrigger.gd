# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name MethodTrigger extends RefCounted
## Class to store info for method triggers


## The uuid of the object
var _uuid: String = ""

## The object
var _component: EngineComponent = null

## Method name
var _method_name: String = ""

## Args to pass when calling
var args: Array[Variant] = []

## The method's Callable object
var _method: Callable = Callable()


## Called the method.
func call_method(extra_args: Array = []) -> void:
	if _method.is_valid():
		_method.callv(extra_args + args)


## Sets the uuid
func set_uuid(p_uuid: String) -> void:
	_uuid = p_uuid
	_component = null
	_method = Callable()
	
	ComponentDB.request_component(_uuid, _on_component_found)


## Sets the method name
func set_method_name(p_method_name: String) -> void:
	_method_name = p_method_name
	_try_set_method()


## Getters for the values
func get_uuid() -> String: return _uuid
func get_method_name() -> String: return _method_name


## Trys to set the method from the object and method name
func _try_set_method() -> void:
	if is_instance_valid(_component) and _component.accessible_methods.has(_method_name):
		_method = _component.accessible_methods[_method_name].set


## Called when ComponentDB finds the component
func _on_component_found(component: EngineComponent) -> void:
	_component = component
	_try_set_method()


## Saves this MethodTrigger into a dictionary
func seralize() -> Dictionary:
	return {
		"uuid": _uuid,
		"method_name": _method_name,
		"args": args
	}.duplicate(true)


## Loads this MethodTrigger from a dictionary
func deseralize(seralized_data: Dictionary) -> MethodTrigger:
	set_uuid(seralized_data.get("uuid", ""))
	set_method_name(seralized_data.get("method_name", ""))
	
	args = seralized_data.get("args", [])
	
	return self

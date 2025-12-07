# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details

class_name ClassTreeConfig extends Object
## Config entry for SearchableClassTree


## The current class tree
var _class_tree: Dictionary = {}

## The Inheritance map of current classes
var _inheritance_map: Dictionary = {}

## Callable to check if a class is hidden
var _is_hidden_callable: Callable = Callable()

## Callable to get all objects that extend a given classname
var _get_objects_by_classname: Callable = Callable()

## Callable to get the classname from an object
var _get_object_classname: Callable = Callable()

## Callable to get the classname from an object
var _get_object_name: Callable = Callable()

## Callable to check if one class extends the other
var _get_class_extends: Callable = Callable()

## Callable to create an object with a given classname, should return a promise
var _create_callable: Callable = Callable()


## Init
func _init(p_class_tree: Dictionary, p_inheritance_map: Dictionary, p_hidden_callable: Callable, p_get_objects_by_classname_callable: Callable, p_get_object_classname_callable: Callable, p_get_object_name_callable: Callable, p_get_class_extends: Callable, p_create_callable: Callable) -> void:
	_class_tree = p_class_tree
	_inheritance_map = p_inheritance_map
	_is_hidden_callable = p_hidden_callable
	_get_objects_by_classname = p_get_objects_by_classname_callable
	_get_object_classname = p_get_object_classname_callable
	_get_object_name = p_get_object_name_callable
	_get_class_extends = p_get_class_extends
	_create_callable = p_create_callable


## Gets the class tree
func get_class_tree() -> Dictionary:
	return _class_tree


## Gets the inheritancemap
func get_inheritance_map() -> Dictionary:
	return _inheritance_map


## Checks if the given classname is hidden
func is_class_hidden(p_classname: String) -> bool:
	return _is_hidden_callable.call(p_classname)


## Gets all objects that extend the given classname
func get_objects_by_classname(p_classname: String) -> Array:
	return _get_objects_by_classname.call(p_classname)


## Gets an objects classname
func get_object_classname(p_object: Object) -> String:
	return _get_object_classname.call(p_object)


## Gets an objects name
func get_object_name(p_object: Object) -> String:
	return _get_object_name.call(p_object)


## Checks if p_base extends p_extends
func does_class_extend(p_base: String, p_extends: String) -> bool:
	return _get_class_extends.call(p_base, p_extends)


## Creates the given object
func create_object(p_classname: String) -> Promise:
	if _create_callable.is_valid():
		var result: Variant = _create_callable.call(p_classname)
		
		if result is Promise:
			return result
		else:
			return Promise.new().auto_resolve([result])
	else:
		return Promise.new().auto_reject()

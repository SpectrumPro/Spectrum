# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details

class_name ClassTreeConfig extends Object
## Config entry for SearchableClassTree


## The current class tree
var _class_tree: Dictionary = {}

## Callable to check if a class is hidden
var _is_hidden_callable: Callable = Callable()

## Callable to get all objects that extend a given classname
var _get_objects_by_classname: Callable = Callable()

## Callable to get the classname from an object
var _get_object_classname: Callable = Callable()

## Callable to get the classname from an object
var _get_object_name: Callable = Callable()


## Init
func _init(p_class_tree: Dictionary, p_hidden_callable: Callable, p_get_objects_by_classname_callable: Callable, p_get_object_classname_callable: Callable, p_get_object_name_callable: Callable) -> void:
	_class_tree = p_class_tree
	_is_hidden_callable = p_hidden_callable
	_get_objects_by_classname = p_get_objects_by_classname_callable
	_get_object_classname = p_get_object_classname_callable
	_get_object_name = p_get_object_name_callable


## Gets the class tree
func get_class_tree() -> Dictionary:
	return _class_tree


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

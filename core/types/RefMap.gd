# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name RefMap extends RefCounted
## A bidirectional mapping class for two-way key-value relationships.


## Dictonary repsenting the normal mapping
var _left: Dictionary = {}

## Dictionary representing the flipped mapping
var _right: Dictionary = {}


## Maps 2 items, returning false if the map failed
func map(left: Variant, right: Variant) -> void:
	_left[left] = right
	_right[right] = left


## Creates a new RefMap from a Dictionary
static func from(dictionary: Dictionary) -> RefMap:
	var map: RefMap = RefMap.new()
	
	for key: Variant in dictionary:
		map.map(key, dictionary[key])
		
	return map


## Gets an item from the map using the left key
func left(key: Variant) -> Variant:
	return _left.get(key, null)


## Gets an item from the map using the right key
func right(key: Variant) -> Variant:
	return _right.get(key, null)


## Erases an item from the map using the left key
func erase_left(key: Variant) -> void:
	var right: Variant = left(key)
	_right.erase(right)
	_left.erase(key)


## Erases an item from the map using the right key
func erase_right(key: Variant) -> void:
	var left: Variant = right(key)
	_left.erase(left)
	_right.erase(key)


## Returns all left keys
func get_left() -> Array:
	return _left.keys()


## Returns all the right keys
func get_right() -> Array:
	return _right.keys()


## Checks if the left side has a variant
func has_left(variant: Variant) -> bool:
	return _left.has(variant)


## Checks if the left side has a variant
func has_right(variant: Variant) -> bool:
	return _right.has(variant)


## Gets this RefMap as a dictonary
func get_as_dict() -> Dictionary:
	return _left.duplicate()


## Clears the RefMap
func clear() -> void:
	_left.clear()
	_right.clear()


func _to_string() -> String:
	return str(_left)

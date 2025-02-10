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


func _to_string() -> String:
	return str(_left)

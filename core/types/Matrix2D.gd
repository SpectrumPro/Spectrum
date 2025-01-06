# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name Matrix2D extends RefCounted
## Implements a two-dimensional data matrix, storing Variants in a structured two-dimensional dictionary. 



## Nested dictionary that stores the two-dimensional position infomation using keys.
##  {
##      y1: {x1: value, x2: value, x3: value, ...}
##      y2: {x1: value, x2: value, x3: value, ...}
##      y2: {x1: value, x2: value, x3: value, ...}
##  }
var _matrix: Dictionary

## Contains all the items in one dictionary
var _all: Dictionary



## Gets a value in two-dimensional space, or null if none is found
func get_xy(position: Vector2i, default: Variant = null) -> Variant:
	return _matrix.get(position.y, {}).get(position.x, default)


## Sets a value in two-dimensional space
func set_xy(value: Variant, position: Vector2i) -> void:
	if not _matrix.has(position.y):
		_matrix[position.y] = {}
	
	_matrix[position.y][position.x] = value
	_all[position] = value


## Erases data from this matrix
func erase_xy(position: Vector2) -> bool:
	_all.erase(position)
	return _matrix.get(position.y, {}).erase(position.x)


## Returns all the items in the matrix in one dictionary
func all() -> Dictionary:
	return _all.duplicate()


## Converts this matrix to a string
func _to_string() -> String:
	var output: String = ""

	for y: int in _matrix.keys():
		for x: int in _matrix[y]:
			output += "(" + str(y) + ", " + str(x) + ") : " + str(_matrix[y][x]) + "\n"
		
	return output

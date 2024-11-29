# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name ComponentClassList extends Node
## Contains a list of all the classes that can be networked, stored here so they can be found when deserializing a network request


## Emitted when the list of function classes is updates
signal function_classes_updated()

## Emitted when the list of output classes is updates
signal output_classes_updated()


## Contains all the classes in this engine, will merge component_class_table, function_class_table, and output_class_table
var global_class_table: Dictionary = {} : get = get_global_class_list


## Contains all the core component classes
var component_class_table: Dictionary = {
	"Universe": Universe,
	"Fixture": Fixture,
	"Programmer": Programmer,
}


## Contains all the function classes
var function_class_table: Dictionary = {
	"Scene": Scene,
	"CueList": CueList,
}


## Contains all the output plugin classes
var output_class_table: Dictionary = {
	"ArtNetOutput": ArtNetOutput
}

## Contains the class name string of all the objects that need to be load() instantainsualy, instead of using call_deferred
var insta_load_objects: Array = [
	"Cue",
	"Fixture"
]


## Stores the default icons for all the classes
var icon_class_list: Dictionary = {
	"EngineComponent": load("res://assets/icons/Component.svg"),
	"Universe": load("res://assets/icons/Universe.svg"),
	"Fixture": load("res://assets/icons/Fixture.svg"),
	"Programmer": load("res://assets/icons/Programmer.svg"),
	"Cue": load("res://assets/icons/Cue.svg"),
	"Scene": load("res://assets/icons/Scene.svg"),
	"CueList": load("res://assets/icons/CueList.svg"),
}


## All of the class names for all valid functions types on the server
var _function_classes: Array = [] : 
	set(value):
		_function_classes = value
		function_classes_updated.emit()

## All of the class names for all valid output types on the server
var _output_classes: Array = [] :
	set(value):
		_output_classes = value
		output_classes_updated.emit()


func _ready() -> void:
	# Gets the function and output classes from the server 
	Client.connected_to_server.connect(func ():
		Client.send_command("classlist", "get_function_classes", [], func(classes: Array): _function_classes = classes)
		Client.send_command("classlist", "get_output_classes", [], func(classes: Array): _output_classes = classes)
	)


## Returns all the function classes
func get_function_classes() -> Array: return _function_classes.duplicate()

## Returns all the output classes
func get_output_classes() -> Array: return _output_classes.duplicate()


## Gets all the classes
func get_global_class_list() -> Dictionary:
	var merged_list = component_class_table.duplicate()
	merged_list.merge(function_class_table)
	merged_list.merge(output_class_table)
		
	return merged_list


## Gets a class icon
func get_class_icon(class_name_string: String) -> Texture2D:
	return icon_class_list.get(class_name_string, load("res://assets/icons/Component.svg"))

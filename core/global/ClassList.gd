# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name ComponentClassList extends Node
## Contains a list of all the classes that can be networked, stored here so they can be found when deserializing a network request


## Emitted when the list of server classes is updated
signal server_classes_updated()


## Contains all the classes in this engine, will merge component_class_table, function_class_table, and output_class_table
var global_class_table: Dictionary = {} : get = get_global_class_list


## Contains all the core component classes
var component_class_table: Dictionary = {
	"Universe": Universe,
	"Fixture": Fixture,
	"FixtureGroupItem": FixtureGroupItem
}
var server_component_class_table: Array

## Contains all the function classes
var function_class_table: Dictionary = {
	"Scene": Scene,
	"CueList": CueList,
	"Function": Function,
	"FixtureGroup": FixtureGroup,
}
var server_function_class_table: Array

## Contains all the data container classes
var data_container_class_tabe: Dictionary = {
	"DataPaletteItem": DataPaletteItem,
	"Cue": Cue,
	"FixtureGroupItem": FixtureGroupItem
	
}
var server_data_container_class_table

## Contains all the output plugin classes
var output_class_table: Dictionary = {
	"ArtNetOutput": ArtNetOutput
}
var server_output_class_table: Array

func _ready() -> void:
	# Gets the function and output classes from the server 
	Client.connected_to_server.connect(func ():
		Client.send_command("classlist", "get_global_class_list_keys", []).then( func(classes: Dictionary): 
			server_component_class_table = classes.get("component_class_table", {})
			server_function_class_table = classes.get("function_class_table", {})
			server_output_class_table = classes.get("output_class_table", {})
			server_data_container_class_table = classes.get("server_data_container_class_table", {})
			
			server_classes_updated.emit()
		)
	)


## Gets all the classes
func get_global_class_list() -> Dictionary:
	var merged_list = component_class_table.duplicate()
	merged_list.merge(function_class_table)
	merged_list.merge(output_class_table)
	merged_list.merge(data_container_class_tabe)
		
	return merged_list

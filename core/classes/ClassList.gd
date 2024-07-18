# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name ClassList extends RefCounted
## Contains a list of all the classes that can be networked, stored here so they can be found when deserializing a network request


## Contains all the classes in this engine, will merge component_class_table, function_class_table, and output_class_table
static var global_class_table: Dictionary = {} : get = get_global_class_list


## Contains all the core component classes
static var component_class_table: Dictionary = {
	"Universe": Universe,
	"Fixture": Fixture,
	"Programmer": Programmer,
	"Cue": Cue
}


## Contains all the function classes
static var function_class_table: Dictionary = {
	"Scene": Scene,
	"CueList": CueList,
}


## Contains all the output plugin classes
static var output_class_table: Dictionary = {
	"ArtNetOutput": ArtNetOutput
}


static func get_global_class_list() -> Dictionary:
	var merged_list = component_class_table.duplicate()
	merged_list.merge(function_class_table)
	merged_list.merge(output_class_table)
		
	return merged_list

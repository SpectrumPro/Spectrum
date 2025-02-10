# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name CoreEngine extends Node
## The client side engine that powers Spectrum


## Emitted when components are added to the engine
signal components_added(components: Array[EngineComponent])

## Emitted when components are removed from the engine
signal components_removed(components: Array[EngineComponent])

## Emitted when this engine is about to reset
signal resetting()

## Emited when the file name is changed
signal file_name_changed()

## Emitted when this engine has finished loading
signal load_finished()

## Used to see if the engine should reset when connecting to a server
var _is_engine_fresh: bool = true

## The current file name
var _current_file_name: String = ""


var network_config: Dictionary = {
	"callbacks": {
		"on_components_added": _add_components,
		"on_components_removed": _remove_components,
		"on_resetting": _reset,
		"on_file_name_changed": _set_file_name,
	}
}


var EngineConfig = {
	## Network objects will be auto added to the servers networked objects index
	"network_objects": [
		{
			"object": (self),
			"name": "engine"
		},
		{
			"object": (Programmer),
			"name": "programmer"
		},
		{
			"object": (FixtureLibrary),
			"name": "FixtureLibrary"
		},
		{
			"object": (ClassList),
			"name": "classlist"
		},
	],
	## Root classes are the primary classes that will be seralized and loaded 
	"root_classes": [
		"Universe",
		"Function"
	]
}


func _ready() -> void:
	Details.print_startup_detils()
	
	_add_auto_network_classes.call_deferred()
	MainSocketClient.connected_to_server.connect(_on_connected_to_server)
	Client.connect_to_server()


## Adds network objects as specifyed in EngineConfig
func _add_auto_network_classes() -> void:
	for config: Dictionary in EngineConfig.network_objects:
		Client.add_networked_object(config.name, config.object)


## Called when we connect to the server
func _on_connected_to_server() -> void:
	if not _is_engine_fresh:
		_reset()
		
	_is_engine_fresh = false
	_load_from_server()


## Requests the current state from the server and loads it localy
func _load_from_server() -> void:
	Client.send_command("engine", "serialize", []).then(func (responce):
		_load_from(responce)
	)


## Loads this engine from serialized data
func _load_from(serialized_data: Dictionary) -> void:
	_set_file_name(str(serialized_data.get("file_name", "")))
	
	var just_added_universes: Array[Universe] = []
	
	for universe_uuid: String in serialized_data.get("Universe", {}).keys():
		var new_universe: Universe = Universe.new(universe_uuid, serialized_data.Universe[universe_uuid].name)
		
		just_added_universes.append(new_universe)
		new_universe.load.call_deferred(serialized_data.Universe[universe_uuid])
	
	_add_components(just_added_universes)
	
	var just_added_functions: Array[Function] = []
	# Loops through each function in the save file (if any), and adds them into the engine
	for function_uuid: String in serialized_data.get("Function", {}):
		var classname: String = serialized_data.Function[function_uuid].get("class_name", "")
		if ClassList.has_class(classname, "Function"):
			var new_function: Function = ClassList.get_class_script(classname).new(function_uuid, serialized_data.Function[function_uuid].name)
			
			just_added_functions.append(new_function)
			new_function.load.call_deferred(serialized_data.Function[function_uuid])
	
	_add_components(just_added_functions)
	
	load_finished.emit()


## Returns a serialized copy of the engine from the server
func serialize() -> Promise: 
	return Client.send_command("engine", "serialize")

## Saves this file to disk on the server
func save(file_name: String = _current_file_name) -> Promise: 
	return Client.send_command("engine", "save", [file_name])

## Loads a file on the server
func load_from_file(file_name: String) -> Promise: 
	return Client.send_command("engine", "load_from_file", [file_name])

## Resets and loads from a new file
func reset_and_load(file_name: String) -> Promise:
	return Client.send_command("engine", "reset_and_load", [file_name])


## Gets all the save files from the library
func get_all_saves_from_library() -> Promise: return Client.send_command("engine", "get_all_saves_from_library")


## Gets the current file name
func get_file_name() -> String: return _current_file_name

## Sets the current file name
func _set_file_name(p_file_name: String) -> void:
	_current_file_name = p_file_name
	file_name_changed.emit(_current_file_name)


## Renames a save file
func rename_file(orignal_name: String, new_name: String) -> Promise: return Client.send_command("engine", "rename_file", [orignal_name, new_name])

## Deletes a save file
func delete_file(file_name: String) -> Promise: return Client.send_command("engine", "delete_file", [file_name])


## Resets the server engine to the default state
func reset() -> Promise: return Client.send_command("engine", "reset")

## Internal: Resets this engine to its default state
func _reset():
	print("Performing Engine Reset!")
	_set_file_name("")
	resetting.emit()  
	
	for object_class_name: String in EngineConfig.root_classes:
		for component: EngineComponent in ComponentDB.get_components_by_classname(object_class_name):
			component.local_delete()


## Creates and adds a new component using the classname to get the type, will return null if the class is not found
func create_component(classname: String, name: String = "") -> Promise: 
	return Client.send_command("engine", "create_component", [classname, name])


## Server: Adds a component to the engine
func add_component(component: EngineComponent) -> void: Client.send_command("engine", "add_component", [component])

## Internal: Adds a new component to this engine
func _add_component(component: EngineComponent, no_signal: bool = false) -> EngineComponent:
	
	# Check if this component is not already apart of this engine
	if not component in ComponentDB.components.values():
		ComponentDB.register_component(component)
		
		if not no_signal:
			components_added.emit([component])
		
	else:
		print("Component: ", component.uuid, " is already in this engine")
	
	return component


## Server: Adds mutiple componets to this engine at once
func add_components(components: Array) -> void: Client.send_command("engine", "add_components", [components])

## Internal: Adds mutiple components to this engine at once
func _add_components(components: Array, no_signal: bool = false) -> Array[EngineComponent]:
	var just_added_components: Array[EngineComponent]
	
	# Loop though all the components requeted, and check there type
	for component in components:
		if component is EngineComponent:
			just_added_components.append(_add_component(component, true))
	
	components_added.emit(just_added_components)
	
	return just_added_components


## Server: Removes a component from this engine
func remove_component(component: EngineComponent) -> void: Client.send_command("engine", "remove_component", [component])

## Internal: Removes a universe from this engine
func _remove_component(component: EngineComponent, no_signal: bool = false) -> bool:
	# Check if this universe is part of this engine
	if component in ComponentDB.components.values():
		ComponentDB.deregister_component(component)
		
		if not no_signal:
			components_removed.emit([component])
		
		return true
		
	# If not return false
	else:
		print("Component: ", component.uuid, " is not part of this engine")
		return false


## Server: Removes mutiple components at once
func remove_components(components: Array) -> void: Client.send_command("engine", "remove_components", [components])

## Internal: Removes mutiple universes at once from this engine
func _remove_components(components: Array, no_signal: bool = false) -> void:
	var just_removed_components: Array = []
	
	for component in components:
		if component is EngineComponent:
			if _remove_component(component, true):
				just_removed_components.append(component)
	
	if not no_signal and just_removed_components:
		components_removed.emit(just_removed_components)

# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name CoreEngine extends Node
## The client side engine that powers Spectrum


## Emitted when components are added to the engine
signal components_added(components: Array[EngineComponent])

## Emitted when components are removed from the engine
signal components_removed(components: Array[EngineComponent])


## Emitted when this engine is about to reset
signal resetting

## Emitted when this engine has finished loading
signal load_finished


## Output frequency of this engine, defaults to 45hz. defined as 1.0 / desired frequency
var call_interval: float = 1.0 / 45.0  # 1 second divided by 45

## The programmer used for programming vixtures, and saving them to scenes, this programmer is not a networked object, and is only stored localy
var programmer: Programmer = Programmer.new()


var server_ip_address: String = "127.0.0.1"
var server_websocket_port: int = 3824
var server_udp_port: int = 3823


## Used to see if the engine should reset when connecting to a server
var _is_engine_fresh: bool = true

## Defines if the client is expecting to disconnect from the server
var is_expecting_disconnect: bool = false


func _ready() -> void:
	Client.add_networked_object("engine", self)
	
	MainSocketClient.connected_to_server.connect(func() :
		_is_engine_fresh = false
		is_expecting_disconnect = false
		load_from_server()
	)
	
	connect_to_server(server_ip_address)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload"):
		connect_to_server(server_ip_address)


## Connects to the server
func connect_to_server(ip: String):
	
	if not _is_engine_fresh:
		reset()
	
	server_ip_address = ip
	Client.connect_to_server(server_ip_address, server_websocket_port, server_udp_port)


## Resets the engine
func reset() -> void:
	resetting.emit()
	disconnect_from_server()
	
	Client.add_networked_object("engine", self)
	Values.reset()
	
	print("Performing Engine Reset!")


## Disconnects from the server
func disconnect_from_server() -> void:
	is_expecting_disconnect = true
	Client.disconnect_from_server()


## Requests the current state from the server and loads it localy
func load_from_server() -> void:
	Client.send_command("engine", "serialize", [], func (responce):
		load_from(responce)
	)


## Creates and adds a new component using the classname to get the type, will return null if the class is not found
func create_component(classname: String, name: String = "", callback: Callable = Callable()) -> void: 
	Client.send_command("engine", "create_component", [classname, name], callback)


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
func add_components(components: Array[EngineComponent]) -> void: Client.send_command("engine", "add_components", [components])

## Internal: Adds mutiple components to this engine at once
func _add_components(components: Array, no_signal: bool = false) -> Array[EngineComponent]:
	var just_added_components: Array[EngineComponent]
	
	# Loop though all the components requeted, and check there type
	for component in components:
		if component is EngineComponent:
			just_added_components.append(_add_component(component, true))
	
	components_added.emit(just_added_components)
	
	return just_added_components

## Callback: Called when components are added on the server
func on_components_added(components: Array) -> void: _add_components(components)


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
func remove_components(components: Array[EngineComponent]) -> void: Client.send_command("engine", "remove_components", [components])

## Internal: Removes mutiple universes at once from this engine
func _remove_components(components: Array, no_signal: bool = false) -> void:
	var just_removed_components: Array = []
	
	for component in components:
		if component is EngineComponent:
			if _remove_component(component, true):
				just_removed_components.append(component)
	
	if not no_signal and just_removed_components:
		components_removed.emit(just_removed_components)

## Callback: Called when components are removed on the server
func on_components_removed(components: Array) -> void: _remove_components(components)


## Loads this engine from serialized data
func load_from(serialized_data: Dictionary) -> void:
	var just_added_universes: Array[Universe] = []
	
	for universe_uuid: String in serialized_data.get("Universe", {}).keys():
		var new_universe: Universe = Universe.new(universe_uuid, serialized_data.Universe[universe_uuid].name)
		
		just_added_universes.append(new_universe)
		new_universe.load.call_deferred(serialized_data.Universe[universe_uuid])
	
	_add_components(just_added_universes)
	
	
	var just_added_functions: Array[Function] = []
	# Loops through each function in the save file (if any), and adds them into the engine
	for function_uuid: String in serialized_data.get("Function", {}):
		if serialized_data.Function[function_uuid].get("class_name", "") in ClassList.function_class_table:
			var new_function: Function = ClassList.function_class_table[serialized_data.Function[function_uuid]["class_name"]].new(function_uuid, serialized_data.Function[function_uuid].name)
			
			just_added_functions.append(new_function)
			new_function.load.call_deferred(serialized_data.Function[function_uuid])
	
	_add_components(just_added_functions)
	
	load_finished.emit()

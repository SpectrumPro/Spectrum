# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name CoreEngine extends Node
## The client side engine that powers Spectrum

## Emitted when any of the universes in this engine have there name changed
signal universe_name_changed(universe: Universe, new_name: String) 

## Emited when a universe / universes are added to this engine
signal universes_added(universes: Array[Universe]) 

## Emited when a universe / universes are removed from this engine
signal universes_removed(universes: Array[Universe])


## Emitted when fixtures_definitions are updates
signal fixtures_definitions_updated() 

## Emitted when any of the fixtures in any of the universes in this engine have there name changed
signal fixture_name_changed(fixture: Fixture, new_name: String) 

## Emited when a fixture / fixtures are added to any of the universes in this engine
signal fixtures_added(fixtures: Array[Fixture])

## Emited when a fixture / fixtures are removed from any of the universes in this engine
signal fixtures_removed(fixtures: Array[Fixture])


## Emited when a function / functions are added to this engine
signal functions_added(functions: Array[Function])

## Emited when a function / functions are removed from this engine
signal functions_removed(functions: Array[Function])

## Emitted when a function has its name changed
signal function_name_changed(function: Function, new_name: String) 

## Emitted when this engine is about to reset
signal resetting


## Dictionary containing all universes in this engine
var universes: Dictionary = {} 

## Dictionary containing all fixtures in this engine
var fixtures: Dictionary = {} 

## Dictionary containing all functions in this engine
var functions: Dictionary = {}

## Dictionary containing fixture definiton file
var fixtures_definitions: Dictionary = {} 


## Output frequency of this engine, defaults to 45hz. defined as 1.0 / desired frequency
var call_interval: float = 1.0 / 45.0  # 1 second divided by 45

## The programmer used for programming vixtures, and saving them to scenes, this programmer is not a networked object, and is only stored localy
var programmer: Programmer = Programmer.new()


var server_ip_address: String = "127.0.0.1"
var server_websocket_port: int = 3824
var server_udp_port: int = 3823


## Folowing functions are for connecting universe signals to engine signals, they are defined as vairables so they can be dissconnected when universe is to be deleted
func _universe_on_name_changed(new_name: String, universe: Universe): 
	universe_name_changed.emit(universe, new_name)


func _universe_on_fixture_name_changed(fixture: Fixture, new_name: String):
	fixture_name_changed.emit(fixture, new_name)


func _universe_on_fixtures_added(p_fixtures: Array[Fixture]):
	for fixture: Fixture in p_fixtures:
		fixtures[fixture.uuid] = fixture
	
	fixtures_added.emit(p_fixtures)


func _universe_on_fixtures_removed(p_fixtures: Array):
	for fixture: Fixture in p_fixtures:
		fixtures.erase(fixture.uuid)
	
	fixtures_removed.emit(p_fixtures)


## Stores callables that are connected to universe signals [br]
## When connecting [member Engine._universe_on_name_changed] to the universe, you need to bind the universe object to the callable, using _universe_on_name_changed.bind(universe) [br]
## how ever this has the side effect of creating new refernce and can cause a memory leek, as universes will not be freed [br]
## To counter act this, _universe_signal_connections stored as Universe:Dictionary{"callable": Callable}. Stores the copy of [member Engine._universe_on_name_changed] that is returned when it is .bind(universe) [br]
## This allows the callable to be dissconnected from the universe, and freed from memory
var _universe_signal_connections: Dictionary = {}


## Folowing functions are for connecting Function signals to Engine signals, they are defined as vairables so they can be dissconnected when Functions are to be deleted
func _function_on_name_changed(new_name: String, function: Function) -> void:
	print("Functions: ", function, " Name changed to: ", new_name)
	function_name_changed.emit(function, new_name)


## See _universe_signal_connections for details
var _function_signal_connections: Dictionary = {}


## Used to see if the engine should reset when connecting to a server
var _is_engine_fresh: bool = true


func _ready() -> void:
	Client.add_networked_object("engine", self)
	
	MainSocketClient.connected_to_server.connect(func() :
		_is_engine_fresh = false
		load_from_server()
	)
	
	connect_to_server(server_ip_address)


## Connects to the server
func connect_to_server(ip: String):
	
	if not _is_engine_fresh:
		reset()
	
	server_ip_address = ip
	Client.connect_to_server(server_ip_address, server_websocket_port, server_udp_port)


func reset() -> void:
	resetting.emit()
	

	universes = {} 
	fixtures = {} 
	functions = {}
	fixtures_definitions = {} 
	programmer = Programmer.new()
	
	
	print("Performing Engine Reset!")


func _disconnect_all_signal_methods(sig: Signal) -> void:
	for signal_dict: Dictionary in sig.get_connections():
		sig.disconnect(signal_dict.callable)


## Disconnects from the server
func disconnect_from_server() -> void:
	Client.disconnect_from_server()


func load_from_server() -> void:
	Client.send({
		"for": "engine",
		"call": "get_loaded_fixtures_definitions",
	}, func (responce):
		fixtures_definitions = responce
		fixtures_definitions_updated.emit()
	)
		
	Client.send({
		"for": "engine",
		"call": "serialize",
	}, func (responce):
		print(responce)
		load_from(responce)
	)


## Returns all output plugins into a dictionary containing the uninitialized object, from the folder defined in [param folder]
func get_io_plugins(folder: String) -> Dictionary:
	
	var uninitialized_output_plugins: Dictionary = {}
	
	var output_plugin_folder : DirAccess = DirAccess.open(folder)
	
	for plugin in output_plugin_folder.get_files():
		var uninitialized_plugin = ResourceLoader.load(folder + plugin)
		
		uninitialized_output_plugins[plugin] = uninitialized_plugin
	
	return uninitialized_output_plugins


## Add a universe
func add_universe() -> void:
	var request: Dictionary = {
		"for":"engine",
		"call":"add_universe",
		"args":[
			"New Universe " + str(len(universes) + 1)
		]
	}
	Client.send(request)


## INTERNAL: called when a universe or universes are added to the server
func on_universes_added(p_universes: Array, all_uuids: Array) -> void:
	_add_universes(p_universes)


## INTERNAL: adds a universe or universes to this engine
func _add_universes(p_universes: Array) -> void:
	var just_added_universes: Array[Universe]
	
	for universe in p_universes:
		if universe is Universe:
			
			Client.add_networked_object(universe.uuid, universe, universe.delete_requested)
			_connect_universe_signals(universe)
			
			just_added_universes.append(universe)
			universes[universe.uuid] = universe
	
	if just_added_universes:
		universes_added.emit(just_added_universes)

## Connects all the signals of the new universe to the signals of this engine
func _connect_universe_signals(universe: Universe):
	
	print("Connecting Signals")
	_universe_signal_connections[universe] = {
		"_universe_on_name_changed": _universe_on_name_changed.bind(universe),
		"on_universes_removed": on_universes_removed.bind([universe])
		}
	
	universe.name_changed.connect(_universe_signal_connections[universe]._universe_on_name_changed)
	universe.delete_requested.connect(_universe_signal_connections[universe].on_universes_removed)
	universe.fixture_name_changed.connect(_universe_on_fixture_name_changed)
	universe.fixtures_added.connect(_universe_on_fixtures_added)
	universe.fixtures_removed.connect(_universe_on_fixtures_removed)



## Disconnects all the signals of the universe to the signals of this engine
func _disconnect_universe_signals(universe: Universe):
	
	universe.name_changed.disconnect(_universe_signal_connections[universe]._universe_on_name_changed)
	universe.delete_requested.disconnect(_universe_signal_connections[universe].on_universes_removed)
	universe.fixture_name_changed.disconnect(_universe_on_fixture_name_changed)
	universe.fixtures_added.disconnect(_universe_on_fixtures_added)
	universe.fixtures_removed.disconnect(_universe_on_fixtures_removed)
	
	_universe_signal_connections[universe] = {}
	_universe_signal_connections.erase(universe)


## Removes mutiple universes
func remove_universes(universes_to_remove):
	Client.send({
		"for":"engine",
		"call":"remove_universes",
		"args":[universes_to_remove]
	})


## INTERNAL: called when a universe or universes are removed from the server
func on_universes_removed(universes_to_remove: Array) -> void:
	_remove_universes(universes_to_remove)


func _remove_universes(p_universes: Array) -> void:
	var just_removed_universes: Array[Universe]
	
	for universe: Universe in p_universes:
		# Check if this universe is part of this engine
		if universe in universes.values():
			universes.erase(universe.uuid)
			universe.on_delete_requested()
			
			just_removed_universes.append(universe)
			_disconnect_universe_signals(universe)
		
		else:
			print("Universe: ", universe.uuid, " is not part of this engine")
	
	if just_removed_universes:
		universes_removed.emit(just_removed_universes)


func add_function(name: String, function: Function) -> void:
	Client.add_networked_object(function.uuid, function, function.delete_requested)
	Client.send({
		"for": "engine",
		"call": "add_function",
		"args": [name, function]
	})


func on_functions_added(p_functions: Array, function_uuids: Array) -> void:
	_add_functions(p_functions)


func _add_functions(p_functions: Array) -> void:
	var just_added_functions: Array[Function] = []
	
	for function in p_functions:
		if function is Function:
			functions[function.uuid] = function
			Client.add_networked_object(function.uuid, function, function.delete_requested)
			_connect_function_signals(function)
			just_added_functions.append(function)
	
	if just_added_functions:
		functions_added.emit(just_added_functions)


func _connect_function_signals(function: Function) -> void:
	_function_signal_connections[function] = {
		"_function_on_name_changed": _function_on_name_changed.bind(function),
		"_remove_functions": _remove_functions.bind([function])
		}
	
	function.name_changed.connect(_function_signal_connections[function]._function_on_name_changed)
	function.delete_requested.connect(_function_signal_connections[function]._remove_functions)



func _disconnect_function_signals(function: Function) -> void:
	
	function.name_changed.disconnect(_function_signal_connections[function]._function_on_name_changed)
	function.delete_requested.disconnect(_function_signal_connections[function]._remove_functions)
	
	_function_signal_connections[function] = {}
	_function_signal_connections.erase(function)


func remove_functions(functions: Array) -> void:
	Client.send({
		"for": "engine",
		"call": "remove_functions",
		"args": [functions]
	})

func on_functions_removed(p_functions: Array, uuids: Array) -> void:
	_remove_functions(p_functions)


func _remove_functions(p_functions: Array) -> void:
	var just_removed_functions: Array[Function] = []
	
	for function in p_functions:
		# Check if this function is part of this engine
		if function is Function and function in functions.values():
			functions.erase(function.uuid)
			just_removed_functions.append(function)
			_disconnect_function_signals(function)
		
		else:
			print("Function: ", function.uuid, " is not part of this engine")
	
	if just_removed_functions:
		functions_removed.emit(just_removed_functions)


func load_from(serialized_data: Dictionary) -> void:
	for universe_uuid: String in serialized_data.get("universes", {}).keys():
		var new_universe: Universe = Universe.new(universe_uuid)
		
		_add_universes([new_universe])
		
		new_universe.load(serialized_data.universes[universe_uuid])
		
	
	var just_added_functions: Array[Function] = []
	# Loops through each function in the save file (if any), and adds them into the engine
	for function_uuid: String in serialized_data.get("functions", {}):
		if serialized_data.functions[function_uuid].get("class_name", "") in ClassList.function_class_table:
			var new_function: Function = ClassList.function_class_table[serialized_data.functions[function_uuid]["class_name"]].new(function_uuid)
			
			just_added_functions.append(new_function)
			new_function.load.call_deferred(serialized_data.functions[function_uuid])
	
	_add_functions(just_added_functions)

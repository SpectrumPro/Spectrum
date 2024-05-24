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


## Emited when a scene / scenes are added to this engine
signal scenes_added(scenes: Array[Scene])

## Emited when a scene / scenes are removed from this engine
signal scenes_removed(scenes: Array[Scene])

## Emitted when a scene has tis name changed
signal scene_name_changed(scene: Scene, new_name: String) 



## Dictionary containing all universes in this engine
var universes: Dictionary = {} 

## Dictionary containing all fixtures in this engine
var fixtures: Dictionary = {} 

## Dictionary containing all scenes in this engine
var scenes: Dictionary = {}

## Dictionary containing fixture definiton file
var fixtures_definitions: Dictionary = {} 


## Dictionary containing all of the output plugins, sotred in [member CoreEngine.output_plugin_path]
var output_plugins: Dictionary = {}

## Output frequency of this engine, defaults to 45hz. defined as 1.0 / desired frequency
var call_interval: float = 1.0 / 45.0  # 1 second divided by 45

## The programmer used for programming vixtures, and saving them to scenes, this programmer is not a networked object, and i only stored localy
var programmer: Programmer = Programmer.new()

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


## Folowing functions are for connecting Scene signals to Engine signals, they are defined as vairables so they can be dissconnected when scenes are to be deleted
func _scene_on_name_changed(new_name: String, scene: Scene) -> void:
	print()
	print("Scene: ", scene, " Name changed to: ", new_name)
	scene_name_changed.emit(scene, new_name)


## See _universe_signal_connections for details
var _scene_signal_connections: Dictionary = {}


const output_plugin_path: String = "res://core/output_plugins/" ## File path for output plugin definitons

func _ready() -> void:
	Client.add_networked_object("engine", self)
	
	output_plugins = get_io_plugins(output_plugin_path)
	print(output_plugins)
	MainSocketClient.connected_to_server.connect(func() :
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
	
	var just_removed_universes: Array[Universe]
	
	for universe: Universe in universes_to_remove:
		# Check if this universe is part of this engine
		if universe in universes.values():
			universes.erase(universe.uuid)
			just_removed_universes.append(universe)
			_disconnect_universe_signals(universe)
		
		else:
			print("Universe: ", universe.uuid, " is not part of this engine")
	
	if just_removed_universes:
		universes_removed.emit(just_removed_universes)


func add_scene(name: String, scene: Scene) -> void:
	Client.add_networked_object(scene.uuid, scene, scene.delete_requested)
	Client.send({
		"for": "engine",
		"call": "add_scene",
		"args": [name, scene]
	})


func on_scenes_added(p_scenes: Array, scene_uuids: Array) -> void:
	_add_scenes(p_scenes)


func _add_scenes(p_scenes: Array) -> void:
	var just_added_scenes: Array[Scene] = []
	
	for scene in p_scenes:
		if scene is Scene:
			scenes[scene.uuid] = scene
			Client.add_networked_object(scene.uuid, scene, scene.delete_requested)
			_connect_scene_signals(scene)
			just_added_scenes.append(scene)
	
	if just_added_scenes:
		scenes_added.emit(just_added_scenes)


func _connect_scene_signals(scene: Scene) -> void:
	_scene_signal_connections[scene] = {
		"_scene_on_name_changed": _scene_on_name_changed.bind(scene),
		"_remove_scenes": _remove_scenes.bind([scene])
		}
	
	scene.name_changed.connect(_scene_signal_connections[scene]._scene_on_name_changed)
	scene.delete_requested.connect(_scene_signal_connections[scene]._remove_scenes)



func _disconnect_scene_signals(scene: Scene) -> void:
	
	scene.name_changed.disconnect(_scene_signal_connections[scene]._scene_on_name_changed)
	scene.delete_requested.disconnect(_scene_signal_connections[scene]._remove_scenes)
	
	_scene_signal_connections[scene] = {}
	_scene_signal_connections.erase(scene)


func remove_scenes(scenes: Array) -> void:
	Client.send({
		"for": "engine",
		"call": "remove_scenes",
		"args": [scenes]
	})

func on_scenes_removed(p_scenes: Array, uuids: Array) -> void:
	_remove_scenes(p_scenes)


func _remove_scenes(p_scenes: Array) -> void:
	var just_removed_scenes: Array[Scene] = []
	
	for scene in p_scenes:
		# Check if this scene is part of this engine
		if scene is Scene and scene in scenes.values():
			scenes.erase(scene.uuid)
			just_removed_scenes.append(scene)
			_disconnect_scene_signals(scene)
		
		else:
			print("Scene: ", scene.uuid, " is not part of this engine")
	
	if just_removed_scenes:
		scenes_removed.emit(just_removed_scenes)


func load_from(serialized_data: Dictionary) -> void:
	for universe_uuid: String in serialized_data.get("universes", {}).keys():
		var new_universe: Universe = Universe.new(universe_uuid)
		
		_add_universes([new_universe])
		
		new_universe.load(serialized_data.universes[universe_uuid])
		
	
	for scene_uuid: String in serialized_data.get("scenes", {}).keys():
		var new_scene: Scene = Scene.new(scene_uuid)
		
		_add_scenes([new_scene])
		
		new_scene.load(serialized_data.scenes[scene_uuid])

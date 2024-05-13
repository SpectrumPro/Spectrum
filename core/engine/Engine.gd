# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name CoreEngine extends Node
## The client side engine that powers Spectrum

signal universe_name_changed(universe: Universe, new_name: String) ## Emitted when any of the universes in this engine have there name changed
signal universes_added(universe: Array[Universe])
signal universes_removed(universes: Array[Universe])
signal universe_selection_changed(selected_universes: Array[Universe])

## Emitted when fixtures_definitions are updates
signal fixtures_definitions_updated() 

## Emitted when any of the fixtures in any of the universes in this engine have there name changed
signal fixture_name_changed(fixture: Fixture, new_name: String) 

## Emited when a fixture / fixtures are added to any of the universes in this engine, contains a list of all fixture uuids for server-client synchronization
signal fixtures_added(fixtures: Array[Fixture], fixture_uuids: Array[String])

## Emited when a fixture / fixtures are removed from any of the universes in this engine, contains a list of all fixture uuids for server-client synchronization
signal fixtures_removed(fixtures: Array[Fixture], fixture_uuids: Array[String])


## Dictionary containing all universes in this engine
var universes: Dictionary = {} 

## Dictionary containing all fixtures in this engine
var fixtures: Dictionary = {} 

## Dictionary containing all scenes in this engine
var scenes: Dictionary = {}


## Dictionary containing fixture definiton file
var fixtures_definitions: Dictionary = {} 

func _ready() -> void:
	Client.add_networked_object("engine", self)
	
	MainSocketClient.connected_to_server.connect(func() :
		Client.send({
			"for": "engine",
			"call": "get_loaded_fixtures_definitions",
		}, func (responce):
			fixtures_definitions = responce
			fixtures_definitions_updated.emit()
		)
	
	)


## Add a universe
func new_universe() -> void:
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
	
	var just_added_universes: Array[Universe]
	
	for universe in p_universes:
		if universe is Universe:
			
			Client.add_networked_object(universe.uuid, universe, universe.delete_requested)
			universe.delete_requested.connect(self.on_universes_removed.bind([universe]), CONNECT_ONE_SHOT)
			
			just_added_universes.append(universe)
			universes[universe.uuid] = universe
	
	if just_added_universes:
		universes_added.emit(just_added_universes)


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
			
		else:
			print("Universe: ", universe.uuid, " is not part of this engine")
	
	if just_removed_universes:
		universes_removed.emit(just_removed_universes)
		
		print("Emitting universes_removed: ", just_removed_universes)


## INTERNAL: called when an fixture or fixtures are added to this universe
func on_fixtures_added(p_fixtures: Array, fixture_uuids: Array) -> void:
	var just_added_fixtures: Array[Fixture]
	
	for fixture in p_fixtures:
		if fixture is Fixture:
			
			Client.add_networked_object(fixture.uuid, fixture, fixture.delete_requested)
			fixture.delete_requested.connect(self.on_fixtures_removed.bind([fixture]), CONNECT_ONE_SHOT)
			just_added_fixtures.append(fixture)
			fixtures[fixture.uuid] = fixture
	
	if just_added_fixtures:
		fixtures_added.emit(just_added_fixtures)
		print(fixtures)


func on_fixtures_removed() -> void:
	pass

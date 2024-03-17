# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name CoreEngine extends Node
## The core engine that powers Spectrum

signal universe_name_changed(universe: Universe, new_name: String) ## Emitted when any of the universes in this engine have there name changed
signal universe_output_added(universe: Universe, output: DataIOPlugin) ## Emitted when of the universes 
signal universe_output_removed(universe: Universe, output_uuid: String)

signal universe_added(universe: Universe)
signal universe_removed(universe_uuid: String)

signal fixture_name_changed(fixture: Fixture, new_name)
signal fixture_added(fixture: Array[Fixture])
signal fixture_removed(fixture_uuid: Array[String])
signal fixture_selection_changed(selected_fixtures: Array[Fixture])


var universes: Dictionary = {}
var fixtures_definitions: Dictionary = {}

var selected_fixtures: Array[Fixture] = []

var input_plugins: Dictionary = {}
var output_plugins: Dictionary = {}

const fixture_path: String = "res://core/fixtures/"
const input_plugin_path: String = "res://core/io_plugins/input_plugins/"
const output_plugin_path: String = "res://core/io_plugins/output_plugins/"

var current_file_name: String = ""
var current_file_path: String = ""

var _system: System = System.new()


func _ready() -> void:
	OS.set_low_processor_usage_mode(true)
	reload_io_plugins()
	reload_fixtures()


func save(file_name: String = current_file_name, file_path: String = current_file_name) -> Error:
	return _system.save(self, file_name, file_path)


func new_universe(name: String = "New Universe", no_signal: bool = false) -> Universe:
	## Adds a new universe
	
	var new_universe: Universe = Universe.new()
	new_universe.name = name 
	new_universe.engine = self
	
	universes[new_universe.uuid] = new_universe

	if not no_signal:
		universe_added.emit(new_universe)
	
	_connect_universe_signals(new_universe)
	
	return new_universe


func _connect_universe_signals(universe: Universe):
	## Connects all the signals of the new universe to the signals of this engine
	
	universe.name_changed.connect(
		func(new_name: String):
			universe_name_changed.emit(universe, new_name)
	)
	
	universe.output_added.connect(
		func(output: DataIOPlugin): 
			universe_output_added.emit(universe, output)
	)
	
	universe.output_removed.connect(
		func(output_uuid: String):
			universe_output_removed.emit(universe, output_uuid)
	)
	
	universe.fixture_name_changed.connect(
		func(fixture: Fixture, new_name: String):
			fixture_name_changed.emit(fixture, new_name)
	)
	
	universe.fixture_added.connect(
		func(fixtures: Array[Fixture]):
			fixture_added.emit(fixtures)
	)
	
	universe.fixture_deleted.connect(
		func(fixture_uuids: Array[String]):
			fixture_removed.emit(fixture_uuids)
	)


func delete_universe(universe: Universe, no_signal: bool = false) -> bool: 
	## Deletes a universe
	
	if universe in universes.values():
		
		universe.delete()
		universes.erase(universe.uuid)
		
		var uuid: String = universe.uuid
		
		universe.free()
		
		if not no_signal:
			print("sending signal")
			universe_removed.emit(uuid)
		
		return true

	else:
		return false
		

func serialize_universes() -> Dictionary:
	## Serializes all universes and returnes them in a dictnary 
	
	var serialized_universes: Dictionary = {}
	
	for universe_uuid: String in universes:
		serialized_universes[universe_uuid] = universes[universe_uuid].serialize()
		
	return serialized_universes


func reload_io_plugins() -> void:
	## Loads all output plugins from the folder
	
	output_plugins = {}
	
	var output_plugin_folder : DirAccess = DirAccess.open(output_plugin_path)
	
	for plugin in output_plugin_folder.get_files():
		var uninitialized_plugin = ResourceLoader.load(output_plugin_path + plugin)
		
		var initialized_plugin: DataIOPlugin = uninitialized_plugin.new()
		var plugin_name: String = initialized_plugin.name
		
		if plugin_name in output_plugins.keys():
			plugin_name = plugin_name +  " " + UUID_Util.v4()
		
		output_plugins[plugin_name] = uninitialized_plugin 
		initialized_plugin.free()


func reload_fixtures() -> void:
	## Loads fixture definition files from a folder
	
	fixtures_definitions = {}
	
	var access = DirAccess.open(fixture_path)
	
	for fixture_folder in access.get_directories():
		
		for fixture in access.open(fixture_path+"/"+fixture_folder).get_files():
			
			var manifest_file = FileAccess.open(fixture_path+fixture_folder+"/"+fixture, FileAccess.READ)
			var manifest = JSON.parse_string(manifest_file.get_as_text())
			
			manifest.info.file_path = fixture_path+fixture_folder+"/"+fixture
			
			if fixtures_definitions.has(manifest.info.brand):
				fixtures_definitions[manifest.info.brand][manifest.info.name] = manifest
			else:
				fixtures_definitions[manifest.info.brand] = {manifest.info.name:manifest}


func select_fixtures(fixtures: Array[Fixture]) -> void:
	## Selects all the fixtures pass to this function
	
	for fixture: Fixture in fixtures:
		if fixture not in selected_fixtures:
			selected_fixtures.append(fixture)
			fixture.set_selected(true)
	
	fixture_selection_changed.emit(selected_fixtures)


func set_fixture_selection(fixtures: Array[Fixture]) -> void:
	## Changes the selection to be the fixtures passed to this function
	
	for fixture: Fixture in selected_fixtures:
		fixture.set_selected(false)
		
	selected_fixtures = []
	
	select_fixtures(fixtures)

func deselect_fixtures(fixtures: Array[Fixture]) -> void:
	## Deselects all the fixtures pass to this function
	
	for fixture: Fixture in fixtures:
		if fixture in selected_fixtures:
			selected_fixtures.erase(fixture)
			fixture.set_selected(false)
	
	fixture_selection_changed.emit(selected_fixtures)

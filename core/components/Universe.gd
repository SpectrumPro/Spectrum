# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name Universe extends EngineComponent
## Engine component for handling universes, and there outputs


## Emited when a fixture / fixtures are added to this universe, contains a list of all fixture uuids for server-client synchronization
signal fixtures_added(fixtures: Array[DMXFixture])

## Emited when a fixture / fixtures are removed from this universe, contains a list of all fixture uuids for server-client synchronization
signal fixtures_removed(fixtures: Array[DMXFixture])

## Emited when a output / outputs are added to this universe, contains a list of all output uuids for server-client synchronization
signal outputs_added(outputs: Array[DMXOutput])

## Emited when a output / outputs are removed from this universe, contains a list of all output uuids for server-client synchronization
signal outputs_removed(outputs: Array[DMXOutput])


## Dictionary containing all the fixtures in this universe, stored as channel:Array[fixture]
var _fixture_channels: Dictionary = {} 

## Dictionary containing all the fixtures in this universe, stored as uuid:fixture
var _fixtures: Dictionary = {}

## Dictionary containing all the outputs in this universe
var _outputs: Dictionary = {} 

## Dictionary containing the current dmx data of this universe, this is constantly updated, so modifying this manualy will cause unexpected outcomes
var _dmx_data: Dictionary = {} 

## Stores dmx overrides, sotred at {channel:value}. theese values will always override other data passed to this universe
var _dmx_overrides: Dictionary = {}


## Called when this EngineComponent is ready
func _component_ready() -> void:
	_set_self_class("Universe")
	
	register_callback("on_fixtures_added", _add_fixtures)
	register_callback("on_fixtures_removed", _remove_fixtures)
	register_callback("on_outputs_added", _add_outputs)
	register_callback("on_outputs_removed", _remove_outputs)

## Creates a new output by class name
func create_output(p_output_class_name: String) -> Promise: return rpc("create_output", [p_output_class_name])


## Adds a new output to this universe, returning false if this output can't be added
func add_output(p_output: DMXOutput) -> Promise: return rpc("add_output", [p_output])

## Internal: Adds an output to this universe
func _add_output(p_output: DMXOutput, p_no_signal: bool = false) -> bool:
	if p_output in _outputs.values():
		return false
	
	_outputs[p_output.uuid] = p_output
	
	p_output.delete_requested.connect(_remove_output.bind(p_output), CONNECT_ONE_SHOT)
	ComponentDB.register_component(p_output)
	
	if not p_no_signal:
		outputs_added.emit([p_output])
	
	return true


## Adds mutiple outputs to this univere at once
func add_outputs(p_outputs: Array) -> Promise: return rpc("add_outputs", [p_outputs])

## Internal: Adds mutiple outputs at once
func _add_outputs(p_outputs: Array, p_no_signal: bool = false) -> void:
	var just_added_outputs: Array[DMXOutput] = []

	for output: Variant in p_outputs:
		if output is DMXOutput:
			if _add_output(output, true):
				just_added_outputs.append(output)

	if not p_no_signal and just_added_outputs:
		outputs_added.emit(just_added_outputs)


## Removes a output from this engine
func remove_output(p_output: DMXOutput) -> Promise: return rpc("remove_output", [p_output])

## Internal: Removes a output from this universe
func _remove_output(p_output: DMXOutput, p_no_signal: bool = false) -> bool: 
	if not p_output in _outputs.values():
		return false
	
	ComponentDB.deregister_component(p_output)
	_outputs.erase(p_output.uuid)

	if not p_no_signal:
		outputs_removed.emit([p_output])
	
	return true


## Removes mutiple outputs from this universe
func remove_outputs(p_outputs: Array) -> Promise: return rpc("remove_outputs", [p_outputs])

## Internal: Removes mutiple outputs from this universe
func _remove_outputs(p_outputs: Array, p_no_signal: bool = false) -> void:
	var just_removed_outputs: Array[DMXOutput] = []

	for output: Variant in p_outputs:
		if output is DMXOutput:
			if _remove_output(output, true):
				just_removed_outputs.append(output)
	
	if not p_no_signal and just_removed_outputs:
		outputs_removed.emit(just_removed_outputs)


## Adds a new fixture to this universe
func add_fixture(p_fixture: DMXFixture, p_channel: int = -1) -> Promise: return rpc("add_fixture", [p_fixture, p_channel])

## Internal: Adds a new fixture to this universe
func _add_fixture(p_fixture: DMXFixture, p_channel: int = -1, p_no_signal: bool = false) -> bool:
	if p_fixture in _fixtures.values():
		return false

	var fixture_channel: int = p_fixture.get_channel() if p_channel == -1 else p_channel
	p_fixture._set_channel(fixture_channel)
	
	if not _fixture_channels.get(fixture_channel):
		_fixture_channels[fixture_channel] = []
	
	_fixture_channels[fixture_channel].append(p_fixture)
	_fixtures[p_fixture.uuid] = p_fixture

	ComponentDB.register_component(p_fixture)
	p_fixture.delete_requested.connect(_remove_fixture.bind(p_fixture), CONNECT_ONE_SHOT)

	if not p_no_signal:
		fixtures_added.emit([p_fixture])
	
	return true


## Adds mutiple fixtures to this universe
func add_fixtures(p_fixtures: Array) -> Promise: return rpc("add_fixtures", [p_fixtures])

## Internal: Adds mutiple fixtures to this universe
func _add_fixtures(p_fixtures: Array, p_no_signal: bool = false) -> void:
	var just_added_fixtures: Array[DMXFixture] = []

	for fixture: Variant in p_fixtures:
		if fixture is DMXFixture:
			if _add_fixture(fixture):
				just_added_fixtures.append(fixture)
	
	if not p_no_signal and just_added_fixtures:
		fixtures_added.emit(just_added_fixtures)


## Removes a fixture from this universe
func remove_fixture(p_fixture: DMXFixture) -> Promise: return rpc("remove_fixture", [p_fixture])

## Internal: Removes a fixture from this universe
func _remove_fixture(p_fixture: DMXFixture, p_no_signal: bool = false) -> bool:
	if not p_fixture in _fixtures.values():
		return false
	
	_fixtures.erase(p_fixture.uuid)
	_fixture_channels[p_fixture.get_channel()].erase(p_fixture)
	
	if not _fixture_channels[p_fixture.get_channel()]:
		_fixture_channels.erase(p_fixture.get_channel())
	
	ComponentDB.deregister_component(p_fixture)
	
	if not p_no_signal:
		fixtures_removed.emit([p_fixture])
	
	return true


## Removes mutiple fixtures from this universe
func remove_fixtures(p_fixtures: Array) -> Promise: return rpc("remove_fixtures", [p_fixtures])

## Internal: Removes mutiple fixtures from this universe
func _remove_fixtures(p_fixtures: Array, p_no_signal: bool = false) -> void:
	var just_removed_fixtures: Array[DMXFixture] = []
	
	for fixture: Variant in p_fixtures:
		if fixture is DMXFixture:
			if _remove_fixture(fixture, true):
				just_removed_fixtures.append(fixture)
	
	if not p_no_signal and just_removed_fixtures:
		fixtures_removed.emit(just_removed_fixtures)
		

## Returns all fixture on the given channel
func get_fixture_by_channel(p_channel: int) -> Array[DMXFixture]:
	var fixtures: Array[DMXFixture] = []
	fixtures.assign(_fixture_channels.get(p_channel, []))

	return fixtures


## Gets all the outputs in this universe
func get_outputs() -> Dictionary:
	return _outputs.duplicate()


## Sets a manual dmx channel to the set value
func set_dmx_override(p_channel: int, p_value: int) -> Promise: return rpc("set_dmx_override", [p_channel, p_value])

## Removes a manual dmx override
func remove_dmx_override(p_channel: int) -> Promise: return rpc("remove_dmx_override", [p_channel]) 

## Removes all dmx overrides
func remove_all_dmx_overrides() -> Promise: return rpc("remove_all_dmx_overrides")


## Serializes this universe
func _serialize_request() -> Dictionary:
	var serialized_outputs: Dictionary = {}
	var serialized_fixtures: Dictionary = {}

	for output: DMXOutput in _outputs.values():
		serialized_outputs[output.uuid] = output.serialize()
	
	for channel: int in _fixture_channels.keys():
		serialized_fixtures[str(channel)] = []

		for fixture: DMXFixture in _fixture_channels[channel]:
			serialized_fixtures[str(channel)].append(fixture.serialize())

	return {
		"outputs": serialized_outputs,
		"fixtures": serialized_fixtures
	}


## Called when this universe is to be deleted, see [method EngineComponent.delete]
func _delete_request():
	_remove_outputs(_outputs.values())
	_remove_fixtures(_fixtures.values())


## Loads this universe from a serialised universe
func _load_request(p_serialized_data: Dictionary) -> void:
	var just_added_fixtures: Array[DMXFixture] = []
	var just_added_output: Array[DMXOutput] = []

	for fixture_channel: String in p_serialized_data.get("fixtures", []):
		for serialized_fixture: Dictionary in p_serialized_data.fixtures[fixture_channel]:
			var new_fixture: DMXFixture = DMXFixture.new(serialized_fixture.get("uuid"))
			new_fixture.load(serialized_fixture)
			
			_add_fixture(new_fixture, -1, true)
			just_added_fixtures.append(new_fixture)
	
	for output_uuid: String in p_serialized_data.get("outputs", {}).keys():
		var classname: String = p_serialized_data.outputs[output_uuid].get("class_name", "")
		if ClassList.has_class(classname, "DMXOutput"):
			var new_output: DMXOutput = ClassList.get_class_script(classname).new(output_uuid)
			new_output.load(p_serialized_data.outputs[output_uuid])
			
			_add_output(new_output, true)
			just_added_output.append(new_output)

	if just_added_fixtures:
		fixtures_added.emit(just_added_fixtures)
	
	if just_added_output:
		outputs_added.emit(just_added_output)

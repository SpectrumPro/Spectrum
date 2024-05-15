# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Universe extends EngineComponent
## Enngie class for handling universes, and there outputs

signal fixture_name_changed(fixture: Fixture, new_name: String)
signal fixtures_added(fixtures: Array[Fixture])
signal fixtures_removed(fixtures: Array[Fixture])

signal outputs_added(outputs: Array[DataOutputPlugin])
signal outputs_removed(outputs: Array[DataOutputPlugin])

var fixtures: Dictionary = {} ## Dictionary containing all the fixtures in this universe
var outputs: Dictionary = {} ## Dictionary containing all the outputs in this universe


## Adds an output to this universe
func add_output(name: String, output: DataOutputPlugin):

	Client.send({
		"for":self.uuid,
		"call":"add_output",
		"args":[
			name if name else ("New Output " + str(len(outputs) + 1)),
			output
		]
	})


## INTERNAL: called when an output or output is added to the server
func on_outputs_added(p_outputs: Array, output_uuids: Array) -> void:
	
	var just_added_outputs: Array[DataOutputPlugin]
	
	for output in p_outputs:
		if output is DataOutputPlugin:
			
			Client.add_networked_object(output.uuid, output, output.delete_requested)
			output.delete_requested.connect(self.on_outputs_removed.bind([output]), CONNECT_ONE_SHOT)
			just_added_outputs.append(output)
			outputs[output.uuid] = output
	
	if just_added_outputs:
		outputs_added.emit(just_added_outputs)


## Remove mutiple outputs from this universe
func remove_outputs(p_outputs: Array) -> void:
	Client.send({
		"for":self.uuid,
		"call":"remove_outputs",
		"args":[
				p_outputs
		]
	})


## INTERNAL: called when an output or outputs are removed from this universe
func on_outputs_removed(p_outputs: Array) -> void:
	
	var just_removed_outputs: Array[DataOutputPlugin]
	
	for output in p_outputs:
		if output in outputs.values():
			
			just_removed_outputs.append(output)
			outputs.erase(output.uuid)
	
	if just_removed_outputs:
		outputs_removed.emit(just_removed_outputs)


## Adds mutiple new fixtures to this universe, from a fixture manifest [br]
## [param start_channel] is the first channel that will be asigned [br]
## [param offset] adds a channel gap between each fixture [br]
## Will return false is manifest is not valid, otherwise Array[Fixture]
func add_fixtures_from_manifest(fixture_manifest: Dictionary, mode:int, start_channel: int, quantity:int, offset:int = 0) -> void:
	Client.send({
		"for": self.uuid,
		"call": "add_fixtures_from_manifest",
		"args": [fixture_manifest, mode, start_channel, quantity, offset]
	})


## INTERNAL: called when an fixture or fixtures are added to this universe
func on_fixtures_added(p_fixtures: Array, fixture_uuids: Array) -> void:
	var just_added_fixtures: Array[Fixture]
	
	for fixture in p_fixtures:
		if fixture is Fixture:
			
			Client.add_networked_object(fixture.uuid, fixture, fixture.delete_requested)
			fixture.delete_requested.connect(self._remove_fixtures.bind([fixture]), CONNECT_ONE_SHOT)
			just_added_fixtures.append(fixture)
			fixtures[fixture.uuid] = fixture
	
	if just_added_fixtures:
		fixtures_added.emit(just_added_fixtures)


## INTERNAL: called when an fixture or fixtures are added to this universe
func on_fixtures_removed(p_fixtures: Array, fixture_uuids: Array) -> void:
	_remove_fixtures(p_fixtures)


## INTERNAL: removes a fixture / fixtures from this universe
func _remove_fixtures(p_fixtures: Array) -> void:
	var just_removed_fixtures: Array[Fixture]
	
	for fixture in p_fixtures:
		if fixture in fixtures.values():
			
			just_removed_fixtures.append(fixture)
			fixtures.erase(fixture.uuid)
	
	if just_removed_fixtures:
		fixtures_removed.emit(just_removed_fixtures)


## Serializes this universe
func _on_serialize_request() -> Dictionary:
	
	var serialized_outputs = {}
	var serialized_fixtures = {}
	
	for output: DataOutputPlugin in outputs.values():
		serialized_outputs[output.uuid] = output.serialize()
	
	for fixture: Fixture in fixtures.values():
		serialized_fixtures[fixture.uuid] = fixture.serialize()
		
	
	return {
		"fixtures":serialized_fixtures,
		"outputs":serialized_outputs,
	}


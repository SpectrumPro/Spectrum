# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Universe extends EngineComponent
## Enngie class for handling universes, and there outputs

signal fixture_name_changed(fixture: Fixture, new_name: String)
signal fixtures_added(fixtures: Array[Fixture])
signal fixtures_deleted(fixture_uuids: Array)

signal outputs_added(outputs: Array[DataIOPlugin])
signal outputs_removed(output_uuids: Array[String])

var fixtures: Dictionary = {} ## Dictionary containing all the fixtures in this universe
var outputs: Dictionary = {} ## Dictionary containing all the outputs in this universe

func _on_serialize_request() -> Dictionary:
	## Serializes this universe
	
	var serialized_outputs = {}
	var serialized_fixtures = {}
	
	for output: DataIOPlugin in outputs.values():
		serialized_outputs[output.uuid] = output.serialize()
	
	for fixture: Fixture in fixtures.values():
		serialized_fixtures[fixture.uuid] = fixture.serialize()
		
	
	return {
		"fixtures":serialized_fixtures,
		"outputs":serialized_outputs,
	}


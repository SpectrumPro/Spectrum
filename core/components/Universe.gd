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

var dmx_data: Dictionary = {}

var engine: CoreEngine ## The CoreEngine class this universe belongs to

var last_call_time: float = 0.0

func new_output(type = ArtNetOutput, no_signal: bool = false) -> DataIOPlugin:
	## Adds a new output of type to this universe
	
	var new_output: DataIOPlugin = type.new()
	
	engine.output_timer.connect(new_output.send_packet)
	
	outputs[new_output.uuid] = new_output
	
	if not no_signal:
		outputs_added.emit([new_output])
	
	return new_output


func remove_output(output: DataIOPlugin, no_signal: bool = false) -> void:
	## Removes an output
	
	var uuid = output.uuid
	outputs.erase(uuid)
	
	output.delete()
	output.free()
	
	if not no_signal:
		outputs_removed.emit([uuid])


func remove_outputs(outputs_to_remove: Array, no_signal: bool = false):
	## Remove more than one output at once
	
	var uuids: Array[String] = []
	
	for output: DataIOPlugin in outputs_to_remove:
		uuids.append(output.uuid)
		remove_output(output, true)
	
	if not no_signal:
		outputs_removed.emit(uuids)


func new_fixture(manifest: Dictionary, mode:int, channel: int = -1, quantity:int = 1, offset:int = 0, uuid: String = "", no_signal: bool = false) -> bool:
	## Adds a new fixture to this universe, if the channels are already in use false it returned
	
	if is_channel_used(range(channel, len(manifest.modes.values()[mode].channels))):
		return false
	
	var just_added_fixtures: Array[Fixture] = []
	
	for i: int in range(quantity):
		var channel_index = channel + offset
		channel_index += (len(manifest.modes.values()[mode].channels)) * i
		
		var new_fixture = Fixture.new({
			"universe": self,
			"channel": channel_index,
			"mode": mode,
			"manifest": manifest
		})

		
		fixtures[channel_index] = new_fixture
		engine.fixtures[new_fixture.uuid] = new_fixture
		just_added_fixtures.append(new_fixture)
		
	if not no_signal:
		fixtures_added.emit(just_added_fixtures)
	
	return true

func remove_fixture(fixture: Fixture, no_signal: bool = false):
	## Removes a fixture from this universe
	
	var fixture_uuid: String = fixture.uuid
	
	if fixture in engine.selected_fixtures:
		engine.deselect_fixtures([fixture])
	
	fixtures.erase(fixture.channel)
	engine.fixtures.erase(fixture.uuid)
	fixture.delete()
	fixture.free()
	
	if not no_signal:
		fixtures_deleted.emit([fixture_uuid])


func remove_fixtures(fixtures_to_remove: Array, no_signal: bool = false) -> void:
	## Removes mutiple fixtures at once
	
	var uuids: Array = []
	
	for fixture: Fixture in fixtures_to_remove:
		uuids.append(fixture.uuid)
		remove_fixture(fixture, true)
	
	if not no_signal:
		fixtures_deleted.emit(uuids)


func is_channel_used(channels: Array) -> bool: 
	## Checks if any of the channels in channels are used by another fixture
	return false


func delete():
	## Called when this universe is about to be deleted, it will remove all outputs and fixtures from this universe
	
	remove_fixtures(fixtures.values())
	remove_outputs(outputs.values())


func set_data(data: Dictionary):
	## Set dmx data, layers will be added soom
	dmx_data.merge(data, true)
	_compile_and_send()


func _compile_and_send():
	#var current_time = Time.get_ticks_msec() / 1000.0  # Convert milliseconds to seconds
	#
	#if current_time - last_call_time >= Core.call_interval:
	var compiled_dmx_data: Dictionary = dmx_data
	for output in outputs.values():
		output.set_data(compiled_dmx_data)
		

		#last_call_time = current_time


func serialize() -> Dictionary:
	## Serializes this universe
	
	var serialized_outputs = {}
	var serialized_fixtures = {}
	
	for output: DataIOPlugin in outputs.values():
		serialized_outputs[output.uuid] = output.serialize()
	
	for fixture: Fixture in fixtures.values():
		serialized_fixtures[fixture.uuid] = fixture.serialize()
		
	
	return {
		"name":name,
		"fixtures":serialized_fixtures,
		"outputs":serialized_outputs,
		"user_meta":serialize_meta()
	}


func load_from(serialised_data: Dictionary) -> void:
	## Loads this universe from a serialised universe
	
	self.name = serialised_data.get("name", "")
	
	fixtures = {}
	outputs = {}
	
	for fixture_uuid: String in serialised_data.get("fixtures", {}):
		var serialised_fixture: Dictionary = serialised_data.fixtures[fixture_uuid]
		
		var fixture_brand: String = serialised_fixture.get("meta", {}).get("fixture_brand", "Generic")
		var fixture_name: String = serialised_fixture.get("meta", {}).get("fixture_name", "Dimmer")
		
		var fixture_manifest: Dictionary = Core.fixtures_definitions[fixture_brand][fixture_name]
		var channel: int = serialised_fixture.get("channel", 1)
		
		var new_fixture = Fixture.new({
			"universe": self,
			"channel": channel,
			"mode": serialised_fixture.get("mode", 0),
			"manifest": fixture_manifest,
			"uuid": fixture_uuid
		})
		
		
		fixtures[channel] = new_fixture
		engine.fixtures[new_fixture.uuid] = new_fixture
		
	
	fixtures_added.emit(fixtures.values())
	
	
	for output_uuid: String in serialised_data.get("outputs"):
		var serialised_output: Dictionary = serialised_data.outputs[output_uuid]
		
		var new_output: DataIOPlugin = engine.output_plugins[serialised_output.file].plugin.new(serialised_output)
		new_output.uuid = output_uuid
		engine.output_timer.connect(new_output.send_packet)
		
		
		outputs[new_output.uuid] = new_output
	
	outputs_added.emit(outputs.values())


#func get_fixtures():
	#return universe.fixtures
	#
#func get_fixture(fixture_uuid):
	#pass
#




#
#func set_desk_data(dmx_data):
	#universe.desk_data.merge(dmx_data)
	#_compile_and_send()
#
#func get_desk_data():
	#return universe.desk_data
#


#
#func from(serialized_universe):
	#universe.name = serialized_universe.name
	#universe.uuid = serialized_universe.uuid
	#
	#for fixture_channel in serialized_universe.fixtures:
		#var fixture = serialized_universe.fixtures[fixture_channel]
		#var options = {
			#"channel":int(fixture_channel),
			#"mode":fixture.mode,
			#"name":fixture.display_name,
			#"quantity":1,
			#"offset":0,
			#"virtual_fixtures":fixture.get("virtual_fixtures", [])
		#}
		#new_fixture(Globals.fixtures[fixture.fixture_brand][fixture.fixture_name], options)
	#
	#for output_uuid in serialized_universe.outputs:
		#var input = serialized_universe.outputs[output_uuid]
		#match input.type:
			#"Empty":
				#universe.outputs[output_uuid] = EmptyInput.new()
			#"Art-Net":
				#universe.outputs[output_uuid] = ArtNetOutput.new()
				#universe.outputs[output_uuid].from(input)
				#universe.outputs[output_uuid].connect_to_host()
#

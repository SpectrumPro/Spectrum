# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Universe extends EngineComponent
## Enngie class for handling universes, and there outputs

signal fixture_name_changed(fixture: Fixture, new_name: String)
signal fixture_added(fixtures: Array[Fixture])
signal fixture_deleted(fixture_uuids: Array[String])

signal output_added(output: DataIOPlugin)
signal output_removed(output_uuid: String)

var fixtures: Dictionary = {} ## Dictionary containing all the fixtures in this universe
var outputs: Dictionary = {} ## Dictionary containing all the outputs in this universe

var dmx_data: Dictionary = {}

var engine: CoreEngine ## The CoreEngine class this universe belongs to

func new_output(type = EmptyOutput, no_signal: bool = false) -> DataIOPlugin:
	## Adds a new output of type to this universe
	
	var new_output: DataIOPlugin = type.new()
	
	outputs[new_output.uuid] = new_output
	
	if not no_signal:
		output_added.emit(new_output)
	
	return new_output


func remove_output(output: DataIOPlugin, no_signal: bool = false) -> void:
	## Removes an output
	
	var uuid = output.uuid
	outputs.erase(uuid)
	
	output.delete()
	output.free()
	
	if not no_signal:
		output_removed.emit(uuid)


func new_fixture(manifest: Dictionary, mode:int, channel: int = -1, quantity:int = 1, offset:int = 0, no_signal: bool = false):
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
		just_added_fixtures.append(new_fixture)
		
	if not no_signal:
		fixture_added.emit(just_added_fixtures)


func remove_fixture(fixture: Fixture, no_signal: bool = false):
	## Removes a fixture from this universe
	
	var fixture_uuid: String = fixture.uuid
	
	if fixture in engine.selected_fixtures:
		engine.deselect_fixtures([fixture])
	
	fixtures.erase(fixture.channel)
	fixture.delete()
	fixture.free()
	
	if not no_signal:
		var uuids: Array[String] = [fixture_uuid]
		fixture_deleted.emit(uuids)


func is_channel_used(channels: Array) -> bool: 
	## Checks if any of the channels in channels are used by another fixture
	return false


func delete():
	## Called when this universe is about to be deleted, it will remove all outputs from this universe
	
	for output in outputs.values():
		remove_output(output)


func set_data(data: Dictionary):
	## Set dmx data, layers will be added soom
	dmx_data.merge(data, true)
	_compile_and_send()


func _compile_and_send():
	## Will compile all dmx data in a future version, currently just sends dmx data
	var compiled_dmx_data = dmx_data
	
	for output: DataIOPlugin in outputs:
		output.send_packet(compiled_dmx_data)


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

#func serialize():
	#var serialized_outputs = {}
	#var serialized_fixtures = {}
	#
	#for output_uuid in universe.outputs.keys():
		#serialized_outputs[output_uuid] = universe.outputs[output_uuid].serialize()
	#
	#for fixture_channel in universe.fixtures.keys():
		#var serialized_fixture = universe.fixtures[fixture_channel].serialize()
		#if serialized_fixture:
			#serialized_fixtures[fixture_channel] = serialized_fixture
		#
	#
	#return {
		#"name":universe.name,
		#"uuid":universe.uuid,
		#"fixtures":serialized_fixtures,
		#"inputs":{},
		#"outputs":serialized_outputs,
		#"desk_data":universe.desk_data
	#}
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

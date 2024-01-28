extends Node
class_name Universe

const Art_Net = preload("res://Scripts/Classes/Art_net.gd")
const Empty = preload("res://Scripts/Classes/Empty.gd")
const Fixture = preload("res://Scripts/Classes/Fixture.gd")

var universe = {
	"name": "New Universe",
	"uuid":Globals.new_uuid(),
	"fixtures": {
	},
	"inputs": {
	},
	"outputs": {
		
	},
	"fixture_data":{
		
	},
	"desk_data":{
		
	}
}

func _set_name(new_name):
	universe.name = new_name

func _get_name():
	return universe.name

func get_uuid():
	return universe.uuid

func get_all_outputs():
	return universe.outputs

func get_output(uuid=""):
	if uuid:
		return universe.outputs[uuid]
	return

func new_output(type=""):
	var uuid = Globals.new_uuid()
	universe.outputs[uuid] = {}
	return change_output_type(uuid, type)

func new_fixture(manifest, options):
		
	if options.channel in universe.fixtures:
		return false
	
	for i in range(options.quantity):
		var channel_index = options.channel + options.offset
		channel_index += (len(manifest.modes.values()[options.mode].channels)) * i
		var uuid = Globals.new_uuid()
		var new_fixture = Fixture.new().from(self, manifest, channel_index, options.mode, options.name, uuid)
		
		universe.fixtures[channel_index] = new_fixture
		
	Globals.call_subscription("reload_fixtures")
	
func remove_fixture(channel):
	pass
	
func get_fixtures():
	return universe.fixtures
	
func get_fixture(fixture_uuid):
	pass

func set_fixture_data(data):
	universe.fixture_data.merge(data, true)
	_compile_and_send()

func remove_output(uuid):
	if uuid in universe.outputs.keys():
		universe.outputs[uuid].free()
		universe.outputs.erase(uuid)

func change_output_type(uuid, type):
	if not type: type == "Empty"
	match type:
		"Empty":
			universe.outputs[uuid] = Empty.new()
		"Art-Net":
			universe.outputs[uuid] = Art_Net.new()
			universe.outputs[uuid].connect_to_host()
	return universe.outputs[uuid]

func set_desk_data(dmx_data):
	universe.desk_data.merge(dmx_data)
	_compile_and_send()

func get_desk_data():
	return universe.desk_data

func _compile_and_send():
	var compiled_dmx_data = universe.fixture_data
	compiled_dmx_data.merge(universe.desk_data, true)
	for output in universe.outputs:
		universe.outputs[output].send_packet(compiled_dmx_data)
	print(compiled_dmx_data)
	
func serialize():
	var serialized_outputs = {}
	
	for output_uuid in universe.outputs.keys():
		serialized_outputs[output_uuid] = universe.outputs[output_uuid].serialize()
	
	return {
		"name":universe.name,
		"uuid":universe.uuid,
		"fixtures":{},
		"inputs":{},
		"outputs":serialized_outputs,
		"dmx_data":{},
		"desk_data":universe.desk_data
	}

func from(serialized_universe):
	universe.name = serialized_universe.name
	universe.uuid = serialized_universe.uuid
	
	for output_uuid in serialized_universe.outputs:
		var input = serialized_universe.outputs[output_uuid]
		match input.type:
			"Empty":
				universe.outputs[output_uuid] = Empty.new()
			"Art-Net":
				universe.outputs[output_uuid] = Art_Net.new()
				universe.outputs[output_uuid].from(input)
				universe.outputs[output_uuid].connect_to_host()

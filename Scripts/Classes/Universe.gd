extends Object
class_name Universe

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

func set_universe_name(new_name):
	universe.name = new_name

func get_universe_name():
	return universe.name

func get_uuid():
	return universe.uuid

func get_all_outputs():
	return universe.outputs

func get_output(uuid=""):
	if uuid:
		return universe.outputs[uuid]
	return

func new_output(type=EmptyOutput):
	var uuid = Globals.new_uuid()
	var new_output: DataIOPlugin = type.new()
	new_output.set_uuid(uuid)
	universe.outputs[uuid] = new_output
	return new_output

func new_fixture(manifest, options):
	if options.channel in universe.fixtures:
		return false
	
	for i in range(options.quantity):

		var channel_index = options.channel + options.offset
		channel_index += (len(manifest.modes.values()[options.mode].channels)) * i
		var uuid = Globals.new_uuid()
		var new_fixture = Fixture.new().from(self, manifest, channel_index, options.mode, options.name, uuid, options.get("virtual_fixtures", []))
		
		universe.fixtures[channel_index] = new_fixture
		
	Globals.call_subscription("reload_fixtures")
	
func remove_fixture(fixture):
	universe.fixtures.erase(fixture.config.channel)
	fixture.delete()
	
	var active_fixtures = Globals.get_value("active_fixtures")
	if active_fixtures:
		if fixture in active_fixtures:
			active_fixtures.erase(fixture)
			Globals.set_value("active_fixtures", active_fixtures)
	
func get_fixtures():
	return universe.fixtures
	
func get_fixture(fixture_uuid):
	pass

func set_fixture_data(data):
	universe.fixture_data.merge(data, true)
	_compile_and_send()

func remove_output(output):
	universe.outputs.erase(output.get_uuid())
	output.delete()
	output.free()

func change_output_type(uuid, type):
	if not type: type == EmptyOutput
	universe.outputs[uuid].delete()
	universe.outputs[uuid].free()
	universe.outputs[uuid] = type.new()
	universe.outputs[uuid].set_uuid(uuid)
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
	
func serialize():
	var serialized_outputs = {}
	var serialized_fixtures = {}
	
	for output_uuid in universe.outputs.keys():
		serialized_outputs[output_uuid] = universe.outputs[output_uuid].serialize()
	
	for fixture_channel in universe.fixtures.keys():
		var serialized_fixture = universe.fixtures[fixture_channel].serialize()
		if serialized_fixture:
			serialized_fixtures[fixture_channel] = serialized_fixture
		
	
	return {
		"name":universe.name,
		"uuid":universe.uuid,
		"fixtures":serialized_fixtures,
		"inputs":{},
		"outputs":serialized_outputs,
		"desk_data":universe.desk_data
	}

func from(serialized_universe):
	universe.name = serialized_universe.name
	universe.uuid = serialized_universe.uuid
	
	for fixture_channel in serialized_universe.fixtures:
		var fixture = serialized_universe.fixtures[fixture_channel]
		var options = {
			"channel":int(fixture_channel),
			"mode":fixture.mode,
			"name":fixture.display_name,
			"quantity":1,
			"offset":0,
			"virtual_fixtures":fixture.get("virtual_fixtures", [])
		}
		new_fixture(Globals.fixtures[fixture.fixture_brand][fixture.fixture_name], options)
	
	for output_uuid in serialized_universe.outputs:
		var input = serialized_universe.outputs[output_uuid]
		match input.type:
			"Empty":
				universe.outputs[output_uuid] = EmptyInput.new()
			"Art-Net":
				universe.outputs[output_uuid] = Art_Net_Output.new()
				universe.outputs[output_uuid].from(input)
				universe.outputs[output_uuid].connect_to_host()

func delete():
	for fixture in universe.fixtures.values():
		remove_fixture(fixture)
	
	for output in universe.outputs.values():
		remove_output(output)
		

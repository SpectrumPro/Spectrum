extends Node
class_name Universe

const Art_Net = preload("res://Scripts/Classes/Art_net.gd")
const Empty = preload("res://Scripts/Classes/Empty.gd")


var universe = {
	"name": "New Universe",
	"uuid":Globals.new_uuid(),
	"fixtures:": {
	},
	"inputs": {
	},
	"outputs": {
		
	},
	"dmx_data":{
		
	},
	"desk_data":{
		
	}
}

func _set_name(name):
	universe.name = name

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
	universe.desk_data.merge(dmx_data, true)
	_compile_and_send()

func _compile_and_send():
	var compiled_dmx_data = universe.desk_data
	for output in universe.outputs:
		universe.outputs[output].send_packet(compiled_dmx_data)

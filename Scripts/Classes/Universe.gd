extends Node
class_name Universe

var universe = {
	"name": "New Universe",
	"uuid":Globals.new_uuid(),
	"fixtures:": {
	},
	"inputs": {
	},
	"outputs": {
	}
}

func _set_name(name):
	universe.name = name

func _get_name():
	return universe.name

func get_uuid():
	return universe.uuid

func new_input(type):
	var uuid = Globals.new_uuid()
	match type:
		"Empty":
			universe.inputs[uuid] = {}
		"Art-Net":
			universe.inputs[uuid] = {}

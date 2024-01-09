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

func get_uuid():
	return universe.uuid

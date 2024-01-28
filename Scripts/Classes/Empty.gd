extends Node
class_name Empty

var exposed_values = []
var uuid = ""

func get_io_name():
	return "Empty"

func get_type():
	return "Empty"

func get_uuid():
	return uuid

func set_uuid(new_uuid):
	uuid = new_uuid
	
func delete():
	self.queue_free()

func send_packet(_packet):
	return false

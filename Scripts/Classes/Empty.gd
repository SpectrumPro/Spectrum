extends Node
class_name Empty

var exposed_values = []

func _get_name():
	return "Empty"

func get_type():
	return "Empty"
	
func send_packet(_packet):
	return false

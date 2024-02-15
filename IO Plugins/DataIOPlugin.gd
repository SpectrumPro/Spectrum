extends Object
class_name DataIOPlugin

var type: String = ""
var uuid: String = ""
var name: String = ""

func set_type(new_type:String) -> void:
	type = new_type
	print(self, " Setting Type ", new_type, type)
	
func get_type() -> String:
	return type

func set_uuid(new_uuid:String) -> void:
	uuid = new_uuid

func get_uuid() -> String:
	return uuid

func set_name(new_name: String) -> void:
	name = new_name

func get_name() -> String:
	return name

func send_packet(packet) -> void:
	return

func delete() -> void:
	return

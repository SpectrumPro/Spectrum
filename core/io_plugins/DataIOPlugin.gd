extends EngineComponent
class_name DataIOPlugin

var type: String = ""

func set_type(new_type:String) -> void:
	type = new_type


func get_type() -> String:
	return type


func send_packet(packet) -> void:
	return


func delete() -> void:
	return

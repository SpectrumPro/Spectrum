extends HBoxContainer


func _ready():
	#Core.load(OS.get_environment("HOME") + "/Documents/Spectrum/Test1.spshow")
	pass

func _on_save_pressed() -> void:
	Client.send({
		"for": "engine",
		"call": "save",
		"args": ["Save_File"]
	})


func _on_load_pressed() -> void:
	Client.send({
		"for": "engine",
		"call": "load_from_file",
		"args": ["Save_File"]
	})


func _on_edit_mode_toggled(toggled_on: bool) -> void:
	Interface.set_edit_mode(toggled_on)

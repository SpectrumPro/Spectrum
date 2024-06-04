extends VBoxContainer

func _on_button_pressed() -> void:
	visible = not visible


func _on_save_pressed() -> void:
	Core.programmer.save_to_scene()

extends PanelContainer


func _on_save_to_scene_pressed() -> void:
	Client.send_command("programmer", "save_to_scene")


func _on_save_to_cue_list_pressed() -> void:
	Client.send_command("programmer", "save_to_new_cue_list")

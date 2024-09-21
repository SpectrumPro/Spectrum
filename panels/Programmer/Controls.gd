# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends PanelContainer
## Programmer script to handle Control buttons

func _on_save_to_scene_pressed() -> void:
	Client.send_command("programmer", "save_to_scene", [Values.get_selection_value("selected_fixtures")])


func _on_save_to_cue_list_pressed() -> void:
	Client.send_command("programmer", "save_to_new_cue_list", [Values.get_selection_value("selected_fixtures")])


func _on_locate_pressed() -> void:
	Client.send_command("programmer", "set_locate", [Values.get_selection_value("selected_fixtures"), true])


func _on_import_pressed() -> void:
	Client.send_command("programmer", "import", [Values.get_selection_value("selected_fixtures")])

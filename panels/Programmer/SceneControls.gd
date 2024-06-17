# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends VBoxContainer
## WIP animation system

func _on_button_pressed() -> void:
	visible = not visible


func _on_save_pressed() -> void:
	Core.programmer.save_to_scene()

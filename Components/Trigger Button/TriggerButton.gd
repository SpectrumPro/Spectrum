# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Button
## Ui button to trigger an action on click

signal edit_requested(from: Button)

var control_node: Node

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 2:
			print("Right Clicked")

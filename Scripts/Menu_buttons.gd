# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends HBoxContainer
## Menu bar controls


func _on_file_pressed() -> void:
	$"../SaveLoadPopup".show()


func _on_edit_mode_toggled(toggled_on: bool) -> void:
	Interface.set_edit_mode(toggled_on)


func _on_save_load_close_pressed() -> void:
	$"../SaveLoadPopup".hide()

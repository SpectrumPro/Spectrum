# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends FileDialog
## WIP animation system


func _on_canceled() -> void:
	queue_free()


func _on_file_selected(path: String) -> void:
	queue_free()


func _on_close_requested() -> void:
	queue_free()

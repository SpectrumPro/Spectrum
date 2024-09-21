# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends FileDialog
## WIP animation system


func _on_canceled() -> void:
	queue_free()


func _on_file_selected(path: String) -> void:
	queue_free()


func _on_close_requested() -> void:
	queue_free()

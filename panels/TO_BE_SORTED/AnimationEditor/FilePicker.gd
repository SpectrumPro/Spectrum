# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

extends FileDialog
## WIP animation system


func _on_canceled() -> void:
	queue_free()


func _on_file_selected(path: String) -> void:
	queue_free()


func _on_close_requested() -> void:
	queue_free()

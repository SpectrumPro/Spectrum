# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Node
## A popup window thats always on top, and will close when the main window is clicked again

func _on_close_requested() -> void:
	self.queue_free()

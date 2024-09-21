# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends Node
## A popup window thats always on top, and will close when the main window is clicked again

func _on_close_requested() -> void:
	self.queue_free()

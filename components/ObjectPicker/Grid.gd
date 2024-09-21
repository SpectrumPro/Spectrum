# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends GridContainer
## Grid ui layout for the object picker, will resize the grid to match the current window size

func _on_resized() -> void:
	self.columns = clamp(int(self.size.x / 150), 1, INF)

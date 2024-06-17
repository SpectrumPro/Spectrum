# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends GridContainer
## Grid ui layout for the object picker, will resize the grid to match the current window size

func _on_resized() -> void:
	self.columns = clamp(int(self.size.x / 150), 1, INF)

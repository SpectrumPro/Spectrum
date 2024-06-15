extends GridContainer

func _on_resized() -> void:
	self.columns = clamp(int(self.size.x / 150), 1, INF)

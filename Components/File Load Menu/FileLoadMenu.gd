extends FileDialog

func _any_close_signal() -> void:
	self.queue_free()

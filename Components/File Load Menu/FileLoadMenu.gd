extends FileDialog

func _on_confirmed() -> void:
	self.queue_free()


func _on_close_requested() -> void:
	self.queue_free()

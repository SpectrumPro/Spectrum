extends VBoxContainer

func _on_close_pressed():
	self.queue_free()

extends Node

func _on_close_requested() -> void:
	self.queue_free()

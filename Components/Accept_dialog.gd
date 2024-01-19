extends AcceptDialog

func _on_canceled():
	queue_free()

func _on_confirmed():
	queue_free()

func _on_custom_action(action):
	queue_free()

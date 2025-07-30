extends Button

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_P):
		print(get_signal_connection_list("pressed"))

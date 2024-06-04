extends ColorPicker

func _on_control_resized() -> void:
	size = Vector2(get_parent().size.x, get_parent().size.y)


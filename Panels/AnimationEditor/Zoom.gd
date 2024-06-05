extends Control

@export var controller: NodePath

func _on_h_slider_value_changed(value: float) -> void:
	print(value)
	if value > 0:
		$Padding.custom_minimum_size.x = 0
		$Track.custom_minimum_size.x = value
	elif value < 0:
		$Padding.custom_minimum_size.x = abs(value)
		$Track.custom_minimum_size.x = 0

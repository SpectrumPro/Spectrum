extends ProgressBar

@export_node_path("AnimationPlayer") var animation_player: NodePath

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not (get_node(animation_player) as AnimationPlayer).assigned_animation:
		return

	var current_time: float = (get_node(animation_player) as AnimationPlayer).current_animation_position
	var current_length: float = (get_node(animation_player) as AnimationPlayer).current_animation_length
	value = clamp(remap(current_time, 0, current_length, 0, 100), min_value + 0.05, max_value)

# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends HBoxContainer
## WIP animation system


@export_node_path("AnimationPlayer") var animation_player: NodePath

func _on_play_pressed() -> void:
	(get_node(animation_player) as AnimationPlayer).play()


func _on_pause_pressed() -> void:
		(get_node(animation_player) as AnimationPlayer).pause()

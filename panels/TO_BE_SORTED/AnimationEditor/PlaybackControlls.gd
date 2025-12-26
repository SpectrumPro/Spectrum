# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

extends HBoxContainer
## WIP animation system


@export_node_path("AnimationPlayer") var animation_player: NodePath

func _on_play_pressed() -> void:
	(get_node(animation_player) as AnimationPlayer).play()


func _on_pause_pressed() -> void:
		(get_node(animation_player) as AnimationPlayer).pause()

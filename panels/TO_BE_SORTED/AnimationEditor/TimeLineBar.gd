# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

extends Control
## WIP animation system

@export_node_path("AnimationPlayer") var animation_player: NodePath
@export_node_path("PanelContainer") var controller: NodePath

var font: Font = load("res://assets/font/RubikMonoOne-Regular.ttf")
var min_size_for_full_draw: int = 1300

func _ready() -> void:
	get_node(controller).length_changed.connect(self._draw)


func _draw() -> void:
	var animation_length: int = get_node(controller).animation.length + 1 
	var previous_x: int = 0
	for i in range(animation_length):
		var x: int = remap(i, 0, animation_length, 0, size.x)
		#
		#print(x - previous_x)
		#
		#if not x - previous_x < 16:
			#draw_string(font, Vector2(x, int(font.get_height())-7), str(i), HORIZONTAL_ALIGNMENT_CENTER, -1, 7)
			#previous_x = x
		var height: int = 15 if i % 10 == 0 else 8
		if not self.size.x < min_size_for_full_draw:
			draw_rect(Rect2(x, 0, 1, height), Color.DIM_GRAY, true)
		elif i % 5 == 0:
			draw_rect(Rect2(x, 0, 1, height), Color.DIM_GRAY, true)
			

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			seek(event)
			
	elif event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			seek(event)


func seek(event: InputEventMouse):
	var animation_length: float = (get_node(animation_player) as AnimationPlayer).current_animation_length
	
	var seek_time = remap(event.position.x, 0, self.size.x, 0, animation_length)
	
	(get_node(animation_player) as AnimationPlayer).seek(seek_time, true)

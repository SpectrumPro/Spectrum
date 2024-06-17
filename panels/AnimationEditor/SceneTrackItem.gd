# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## WIP animation system


var is_dragging: bool = false

func _ready() -> void:
	update_anchors()


func update_anchors() -> void:
	$Label.text = "update_anchors"
	var current_pos = position
	var current_size = size
	
	# Get the parent size (assuming the parent is also a Control node)
	var parent_size = get_parent().size
	
	# Calculate the anchor values
	anchor_left = current_pos.x / parent_size.x
	anchor_top = current_pos.y / parent_size.y
	anchor_right = (current_pos.x + current_size.x) / parent_size.x
	anchor_bottom = (current_pos.y + current_size.y) / parent_size.y
	
	# Restore position and size to prevent jumpiness
	position = current_pos
	size = current_size


func _on_left_handle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_dragging = true
		
		var new_x_pos: int = clamp(position.x + event.relative.x, 0, get_parent().size.x)
		var new_size_x: int = size.x
		
		if new_x_pos != 0:
			new_size_x = clamp(size.x - event.relative.x, 5, INF)
		
		if new_size_x == 5:
			return
		
		if not new_x_pos == 0:
			size.x = new_size_x
		position.x = new_x_pos
		
		print()
		print(new_size_x)
		print(new_x_pos)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		is_dragging = false
		update_anchors()


func _on_right_handle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_dragging = true
		
		var new_size_x = clamp(size.x + event.relative.x, 5, INF)
		size.x = new_size_x
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		is_dragging = false
		update_anchors()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_dragging = true
		
		var new_x_pos = clamp(position.x + event.relative.x, 0, get_parent().size.x)
		position.x = new_x_pos
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		is_dragging = false
		update_anchors()

# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UIPanel extends Control
## Base class for all UI Panels


## Emitted when the panel requests to be moved when not in edit mode, by is the distance
signal request_move(by: Vector2)

## Emitted when the panel requests to be resized when not in edit mode, to is the new size
signal request_resize(by: Vector2)


## The move and resize handle, used by UIPanel
@onready var move_resize_handle: Control = null


func _ready() -> void:
	pass


## Sets the move and resize handle
func set_move_resize_handle(node: Control) -> void:
	if is_instance_valid(move_resize_handle): move_resize_handle.gui_input.disconnect(_on_move_resize_gui_input)
	move_resize_handle = node
	move_resize_handle.gui_input.connect(_on_move_resize_gui_input)


## Called for GUI inputs on the move resize handle
func _on_move_resize_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		event = event as InputEventMouseMotion
		match event.button_mask:
			MOUSE_BUTTON_MASK_LEFT:
				request_move.emit(event.screen_relative)
			
			MOUSE_BUTTON_MASK_RIGHT:
				request_resize.emit(event.screen_relative)

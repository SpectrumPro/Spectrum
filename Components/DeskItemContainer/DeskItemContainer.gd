# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer

signal clicked

@onready var _new_position: Vector2 = self.position
@onready var _new_size: Vector2 = self.size
@export_node_path("Label") var label: NodePath

var snapping_enabled: bool = true
var snapping_value: Vector2 = Vector2(10, 10)

@export var selected_color: Color
@export var normal_color: Color

func _ready() -> void:
	$Handles/Background.add_theme_stylebox_override("panel", $Handles/Background.get_theme_stylebox("panel").duplicate())
	update_label()


func set_edit_mode(edit_mode: bool) -> void:
	$Handles.visible = edit_mode


func set_selected(is_selected: bool) -> void:
	$Handles/Background.get_theme_stylebox("panel").bg_color = selected_color if is_selected else normal_color


func update_label() -> void:
	if self.size > Vector2(180, 180):
		get_node(label).text = "W:" + str(size.x) + " H:" + str(size.y) + "\nX:" + str(position.x) + " Y:" + str(position.y)
		get_node(label).label_settings.font_size = 16
	else:
		get_node(label).text = "W:" + str(size.x) + "\nH:" + str(size.y) + "\nX:" + str(position.x) + "\nY:" + str(position.y)
		get_node(label).label_settings.font_size = 10


func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_new_position += event.relative
		_new_position = _new_position.clamp(Vector2.ZERO, get_parent().size - size)
		self.position = _new_position.snapped(snapping_value)
		update_label()
		
	if event.is_pressed():
		clicked.emit()

func _on_br_handle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_new_size += event.relative
		_new_size = _new_size.clamp(custom_minimum_size, Vector2.INF)
		self.size = _new_size.snapped(snapping_value)
		update_label()
	
	if event.is_pressed():
		clicked.emit()

# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends HBoxContainer

@export_node_path("ColorPicker") var color_picker: NodePath

@export_node_path("VSlider") var red_slider: NodePath
@export_node_path("VSlider") var green_slider: NodePath
@export_node_path("VSlider") var blue_slider: NodePath

@onready var red_slider_gradient: Gradient = get_node(red_slider).get_theme_stylebox("slider").texture.gradient
@onready var green_slider_gradient: Gradient = get_node(green_slider).get_theme_stylebox("slider").texture.gradient
@onready var blue_slider_gradient: Gradient = get_node(blue_slider).get_theme_stylebox("slider").texture.gradient

var current_color: Color = Color.BLACK

var _last_call_time: int = 0

func update_slider_bg_colors():
	print(current_color + Color.RED)
	print((current_color - Color.RED).clamp(Color.BLACK, Color.WHITE))
	red_slider_gradient.set_color(0, (current_color - Color.RED).clamp(Color.BLACK, Color.WHITE))
	red_slider_gradient.set_color(1, (current_color + Color.RED).clamp(Color.BLACK, Color.WHITE))

	green_slider_gradient.set_color(0, (current_color - Color.GREEN).clamp(Color.BLACK, Color.WHITE))
	green_slider_gradient.set_color(1, (current_color + Color.GREEN).clamp(Color.BLACK, Color.WHITE))

	blue_slider_gradient.set_color(0, (current_color - Color.BLUE).clamp(Color.BLACK, Color.WHITE))
	blue_slider_gradient.set_color(1, (current_color + Color.BLUE).clamp(Color.BLACK, Color.WHITE))


## Called when the color picker is changed.
func _on_color_picker_color_changed(color: Color) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0  # Convert milliseconds to seconds
	
	if current_time - _last_call_time >= Core.call_interval:
		current_color = color
		Core.programmer.set_color(Values.get_selection_value("selected_fixtures", []), current_color)
		
		get_node(red_slider).value = current_color.r8
		get_node(green_slider).value = current_color.g8
		get_node(blue_slider).value = current_color.b8
		
		update_slider_bg_colors()
		
		_last_call_time = current_time


func _update_color() -> void:
	get_node(color_picker).color = current_color
	update_slider_bg_colors()
	Core.programmer.set_color(Values.get_selection_value("selected_fixtures", []), current_color)


func _on_red_sider_value_changed(value: float) -> void:
	current_color.r8 = value
	_update_color()


func _on_green_slider_value_changed(value: float) -> void:
	current_color.g8 = value
	_update_color()


func _on_blue_slider_value_changed(value: float) -> void:
	current_color.b8 = value
	_update_color()

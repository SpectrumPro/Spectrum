# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends HBoxContainer
## Color system used in the programmer, this scripts is what outputs the color to the programmer on the server, and updates the slider backgrounds


@export_node_path("ColorPicker") var color_picker: NodePath

@onready var red_slider: ChannelSlider = $ColorSliders/HBoxContainer/Red
@onready var green_slider: ChannelSlider = $ColorSliders/HBoxContainer/Green
@onready var blue_slider: ChannelSlider = $ColorSliders/HBoxContainer/Blue

## The current color of this color system
var current_color: Color = Color.BLACK

var _last_call_time: int = 0


## Updates the background of the R G B sliders
func update_slider_bg_colors():
	red_slider.set_graident_bottom_color((current_color - Color.RED).clamp(Color.BLACK, Color.WHITE))
	red_slider.set_graident_top_color((current_color + Color.RED).clamp(Color.BLACK, Color.WHITE))

	green_slider.set_graident_bottom_color((current_color - Color.GREEN).clamp(Color.BLACK, Color.WHITE))
	green_slider.set_graident_top_color((current_color + Color.GREEN).clamp(Color.BLACK, Color.WHITE))

	blue_slider.set_graident_bottom_color((current_color - Color.BLUE).clamp(Color.BLACK, Color.WHITE))
	blue_slider.set_graident_top_color((current_color + Color.BLUE).clamp(Color.BLACK, Color.WHITE))


## Called when the color picker is changed.
func _on_color_picker_color_changed(color: Color) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0  # Convert milliseconds to seconds
	
	if current_time - _last_call_time >= Core.call_interval:
		current_color = color
		Core.programmer.set_color(Values.get_selection_value("selected_fixtures", []), current_color)
		
		red_slider.set_value(current_color.r8)
		green_slider.set_value(current_color.g8)
		blue_slider.set_value(current_color.b8)
		
		update_slider_bg_colors()
		
		_last_call_time = current_time


## Updates the color on the programmer
func _update_color(send_message: bool = true) -> void:
	get_node(color_picker).color = current_color
	update_slider_bg_colors()
	
	if send_message: _send_to_programmer("set_color", current_color)


func _send_to_programmer(method_name: String, value: Variant = null) -> void:
	Client.send({
		"for": "programmer",
		"call": method_name,
		"args": [Values.get_selection_value("selected_fixtures", []), value] if value != null else [Values.get_selection_value("selected_fixtures", [])]
	})


func _on_red_sider_value_changed(value: float) -> void:
	current_color.r8 = value
	_update_color()


func _on_green_slider_value_changed(value: float) -> void:
	current_color.g8 = value
	_update_color()


func _on_blue_slider_value_changed(value: float) -> void:
	current_color.b8 = value
	_update_color()


func _on_color_reset_pressed() -> void: 
	red_slider.set_value(0)
	green_slider.set_value(0)
	blue_slider.set_value(0)
	
	current_color = Color.BLACK
	_update_color(false)
	_send_to_programmer("reset_color")

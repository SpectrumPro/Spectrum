# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends HBoxContainer
## Color system used in the programmer, this scripts is what outputs the color to the programmer on the server, and updates the slider backgrounds


## NodePath to the color picker
@onready var color_picker: ColorPicker  = $ColorSliders/HBoxContainer/ColorPicker/PanelContainer/VBoxContainer/Control/ColorPicker

## RGB Sliders
@onready var red_slider: ChannelSlider = $ColorSliders/HBoxContainer/Red
@onready var green_slider: ChannelSlider = $ColorSliders/HBoxContainer/Green
@onready var blue_slider: ChannelSlider = $ColorSliders/HBoxContainer/Blue

## HSV Sliders
@onready var hue_slider: ChannelSlider = $ColorSliders/HBoxContainer/Hue
@onready var saturation_slider: ChannelSlider = $ColorSliders/HBoxContainer/Saturation
@onready var value_slider: ChannelSlider = $ColorSliders/HBoxContainer/Value

## Disables this input
var disabled: bool = false : set = set_disabled

## The current color of this color system
var current_color: Color = Color.BLACK

## Wether or not to send randomise commands from each slider, or globaly
var send_randomise_command: bool = false : set = set_send_randomise_command

## Used to time the output of the color picker, so we don't dos the server
var _last_call_time: int = 0


func set_send_randomise_command(p_send_randomise_command: bool) -> void:
	send_randomise_command = p_send_randomise_command
	
	red_slider.send_randomise_command = send_randomise_command
	green_slider.send_randomise_command = send_randomise_command
	blue_slider.send_randomise_command = send_randomise_command
	
	hue_slider.send_randomise_command = send_randomise_command
	saturation_slider.send_randomise_command = send_randomise_command
	value_slider.send_randomise_command = send_randomise_command


## Updates the background of the R G B sliders
func update_slider_bg_colors():
	red_slider.set_gradient_top_color((current_color + Color.RED).clamp(Color.BLACK, Color.WHITE))
	red_slider.set_gradient_bottom_color((current_color - Color.RED).clamp(Color.BLACK, Color.WHITE))

	green_slider.set_gradient_top_color((current_color + Color.GREEN).clamp(Color.BLACK, Color.WHITE))
	green_slider.set_gradient_bottom_color((current_color - Color.GREEN).clamp(Color.BLACK, Color.WHITE))

	blue_slider.set_gradient_top_color((current_color + Color.BLUE).clamp(Color.BLACK, Color.WHITE))
	blue_slider.set_gradient_bottom_color((current_color - Color.BLUE).clamp(Color.BLACK, Color.WHITE))
	
	# Convert current_color to HSV
	var hsv_color = Color(current_color)
	
	# Update Saturation slider
	var top_saturation_color = Color.from_hsv(hsv_color.h, 1.0, hsv_color.v)
	var bottom_saturation_color = Color.from_hsv(hsv_color.h, 0.0, hsv_color.v)
	saturation_slider.set_gradient_top_color(top_saturation_color)
	saturation_slider.set_gradient_bottom_color(bottom_saturation_color)

	# Update Value (Brightness) slider
	var top_value_color = Color.from_hsv(hsv_color.h, hsv_color.s, 1.0)
	var bottom_value_color = Color.from_hsv(hsv_color.h, hsv_color.s, 0.0)
	value_slider.set_gradient_top_color(top_value_color)
	value_slider.set_gradient_bottom_color(bottom_value_color)


func set_value(color: Color) -> void:
	current_color = color
	_update_color(false)
	
	_update_rgb()
	_update_hsv()


func show_override_warning(state: bool) -> void:
	$ColorSliders/HBoxContainer/ColorPicker/PanelContainer/WarningBG.visible = state


func reset_no_message() -> void:
	red_slider.reset_no_message()
	green_slider.reset_no_message()
	blue_slider.reset_no_message()
	hue_slider.reset_no_message()
	saturation_slider.reset_no_message()
	value_slider.reset_no_message()
	
	current_color = Color.BLACK
	_update_color(false)
	show_override_warning(false)


func set_disabled(p_disabled: bool) -> void:
	disabled = p_disabled
	
	red_slider.set_disabled(disabled)
	green_slider.set_disabled(disabled)
	blue_slider.set_disabled(disabled)
	hue_slider.set_disabled(disabled)
	saturation_slider.set_disabled(disabled)
	value_slider.set_disabled(disabled)



## Called when the color picker is changed.
func _on_color_picker_color_changed(color: Color) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0  # Convert milliseconds to seconds
	
	if current_time - _last_call_time >= Core.call_interval:
		current_color = color
		Core.programmer.set_color(Values.get_selection_value("selected_fixtures", []), current_color)
		
		_update_rgb()
		_update_hsv()
		show_override_warning(true)
		
		
		update_slider_bg_colors()
		
		_last_call_time = current_time


## Updates the color on the programmer
func _update_color(send_message: bool = true) -> void:
	color_picker.color = current_color
	update_slider_bg_colors()
	
	
	if send_message: 
		_send_to_programmer("set_color", current_color)


func _update_rgb() -> void:
	red_slider.set_value(current_color.r8)
	green_slider.set_value(current_color.g8)
	blue_slider.set_value(current_color.b8)


func _update_hsv() -> void:
	hue_slider.set_value(remap(current_color.h, 0.0, 1.0, 0, 360))
	saturation_slider.set_value(remap(current_color.s, 0.0, 1.0, 0, 255))
	value_slider.set_value(remap(current_color.v, 0.0, 1.0, 0, 255))


func _send_to_programmer(method_name: String, value: Variant = null) -> void:
	Client.send({
		"for": "programmer",
		"call": method_name,
		"args": [Values.get_selection_value("selected_fixtures", []), value] if value != null else [Values.get_selection_value("selected_fixtures", [])]
	})


func _on_red_sider_value_changed(value: float) -> void:
	current_color.r8 = value
	_update_color()
	_update_hsv()
	show_override_warning(true)
	


func _on_green_slider_value_changed(value: float) -> void:
	current_color.g8 = value
	_update_color()
	_update_hsv()
	show_override_warning(true)



func _on_blue_slider_value_changed(value: float) -> void:
	current_color.b8 = value
	_update_color()
	_update_hsv()
	show_override_warning(true)


func _on_color_reset_pressed() -> void: 
	reset_no_message()
	
	_send_to_programmer("reset_color")


func _on_hue_value_changed(value: int) -> void:
	current_color.h = remap(value, 0, 360, 0.0, 1.0)
	_update_color()
	_update_rgb()
	show_override_warning(true)



func _on_saturation_value_changed(value: int) -> void:
	current_color.s = remap(value, 0, 255, 0.0, 1.0)
	_update_color()
	_update_rgb()
	show_override_warning(true)


func _on_value_value_changed(value: int) -> void:
	current_color.v = remap(value, 0, 255, 0.0, 1.0)
	_update_color()
	_update_rgb()
	show_override_warning(true)


func _on_color_mode_tab_changed(tab: int) -> void:
	match tab:
		0: # RGB Mode
			hue_slider.hide()
			saturation_slider.hide()
			value_slider.hide()
			
			red_slider.show()
			green_slider.show()
			blue_slider.show()
			
			color_picker.picker_shape = ColorPicker.SHAPE_VHS_CIRCLE
		1:
			red_slider.hide()
			green_slider.hide()
			blue_slider.hide()
			
			hue_slider.show()
			saturation_slider.show()
			value_slider.show()
			
			color_picker.picker_shape = ColorPicker.SHAPE_HSV_RECTANGLE

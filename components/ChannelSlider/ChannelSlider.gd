# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

@tool
class_name ChannelSlider extends PanelContainer
## The slider used for channel overrides


## Emitted when the value is changed
signal value_changed(value: int)


## The label text
@export var label_text: String = "Slider" : set = set_label_text

## Wether to show the override warning background
@export var show_warning_bg: bool = true : set = set_show_warning_bg

## The slider value
@export_range(0, 255) var value: int = 0 : set = set_value


@export_group("Graident")

## Wether to show the gradient background
@export var show_gradient_bg: bool = false : set = set_show_graident_bg

## Top and Bottom colors of the graident
@export var graident_top_color: Color = Color.WHITE : set = set_graident_top_color
@export var graident_bottom_color: Color = Color.BLACK : set = set_graident_bottom_color


@export_group("Command")

## Wether or not to send a command to the server
@export var send_command: bool = true

## The ID of the networked object
@export var object_id: String = ""

## The method to call
@export var method: String = ""

## The method to call when reseting
@export var reset_method: String = ""



@export_group("Arguments")

## Args to send before the value
@export var args_befour: Array = []

## Args to send after the value
@export var args_after: Array = []

## A selection value to send, "" to disable
@export var send_selection_value: String = ""


## Nodes
@onready var slider: VSlider = $MarginContainer/VBoxContainer/VSlider
@onready var spin_box: SpinBox = $MarginContainer/VBoxContainer/SpinBox
@onready var label: Label = $MarginContainer/VBoxContainer/LabelContainer/Label



func _ready() -> void:
	set_label_text(label_text)
	set_show_warning_bg(show_warning_bg)
	set_show_graident_bg(show_gradient_bg)
	
	set_graident_top_color(graident_top_color)
	set_graident_bottom_color(graident_bottom_color)
	
	set_value(value)
	
	$GraidentContainer.visible = show_gradient_bg
	
	$GraidentContainer/GraidentBG.add_theme_stylebox_override("panel", $GraidentContainer/GraidentBG.get_theme_stylebox("panel").duplicate(true))


## Sets the text in the main label
func set_label_text(text: String):
	label_text = text
	if is_node_ready():  $MarginContainer/VBoxContainer/LabelContainer/Label.text = text


## Sets wether to show the override warning background
func set_show_warning_bg(state: bool) -> void:
	show_warning_bg = state


## Sets wether to show the gradient background
func set_show_graident_bg(state: bool) -> void:
	show_gradient_bg = state
	if is_node_ready(): $GraidentContainer.visible = state


## Sets the top color of the graident
func set_graident_top_color(color: Color) -> void:
	graident_top_color = color
	if is_node_ready(): $GraidentContainer/GraidentBG.get_theme_stylebox("panel").texture.gradient.set_color(1, color)


## Sets the bottom color of the graident
func set_graident_bottom_color(color: Color) -> void:
	graident_bottom_color = color
	if is_node_ready(): $GraidentContainer/GraidentBG.get_theme_stylebox("panel").texture.gradient.set_color(0, color)


## Sets the current value
func set_value(p_value: int) -> void:
	value = clamp(p_value, 0, 255)
	
	if is_node_ready():
		slider.set_value_no_signal(p_value)
		spin_box.set_value_no_signal(p_value)


## Clears the value of the slider with out sending a message
func clear_no_message() -> void:
	value = 0
	if show_warning_bg: $WarningBG.hide()
	
	value_changed.emit(0)


## Sends the value message
func _send_set_value_message(value: int) -> void:
	
	if not send_command: 
		return
	
	var args: Array = []
	
	if send_selection_value:
		args = args_befour + [Values.get_selection_value(send_selection_value, [])] + [value] + args_after 
	else:
		args = args_befour + [value] + args_after 
	
	Client.send({
		"for": object_id,
		"call": method,
		"args": args
	})


## Called when the slider is moved
func _on_v_slider_value_changed(p_value: float) -> void:
	value = p_value
	
	if show_warning_bg: $WarningBG.show()
	_send_set_value_message(value)
	
	value_changed.emit(value)


## Called when the input box is changed
func _on_spin_box_value_changed(p_value: float) -> void:
	value = p_value
	
	if show_warning_bg: $WarningBG.show()
	_send_set_value_message(value)
	
	value_changed.emit()


## Called when the clear button is pressed
func _on_clear_pressed() -> void:
	clear_no_message()
	
	if send_command: Client.send({
		"for": object_id,
		"call": reset_method,
		"args": args_befour if not send_selection_value else args_befour + [Values.get_selection_value(send_selection_value, [])]
	})


## Called when the random button is pressed
func _on_random_pressed() -> void:
	slider.value = randi_range(0, 255)

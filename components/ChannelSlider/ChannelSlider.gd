# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

@tool
class_name ChannelSlider extends PanelContainer
## The slider used for channel overrides


## Emitted when the value is changed
signal value_changed(value: int)

## Emitted when the randomise button is pressed
signal randomise_pressed()

## Emitted when the reset button is pressed
signal reset_pressed()


## The label text
@export var label_text: String = "Slider" : set = set_label_text

## Wether to show the override warning background
@export var show_warning_bg: bool = true : set = set_show_warning_bg

## The max value of the slider
@export var max_value: int = 255 : set = set_max_value

## The slider value
@export var value: int = 0 : set = set_value

## Disables this slider
@export var disabled: bool = false : set = set_disabled


@export_group("Graident")

## Wether to show the gradient background
@export var show_gradient_bg: bool = false : set = set_show_graident_bg

## Top and Bottom colors of the graident
@export var graident_top_color: Color = Color.WHITE : set = set_gradient_top_color
@export var graident_bottom_color: Color = Color.BLACK : set = set_gradient_bottom_color


@export_group("Set Command")

## Wether or not to send a command to the server
@export var send__set_command: bool = true

## The ID of the networked object
@export var object_id: String = ""

## The method to call
@export var method: String = ""


@export_group("Randomise Command")

@export var send_randomise_command: bool = true

@export var show_randomise_button: bool = true : set = set_show_randomise_button

## The method to call when randomising,  "" to disable sending and instead emit value_changed with a random value
@export var randomise_method: String = ""

## Args to send after randomise_method
@export var randomise_args: Array = []


@export_group("Reset Command")

@export var send_reset_command: bool = true

## The method to call when reseting
@export var reset_method: String = ""


@export_group("Arguments")

## Args to send before the value for set and reset
@export var args_befour: Array = []

## Args to send after the value for set and reset
@export var args_after: Array = []

## A selection value to send, "" to disable. Gets send before every set, reset, and randomise call
@export var send_selection_value: String = ""



@export_group("Icons")

@export var reset_icon: Texture2D = load("res://assets/icons/close.svg") : set = set_reset_icon


## Nodes
@onready var slider: VSlider = $MarginContainer/VBoxContainer/VSlider
@onready var spin_box: SpinBox = $MarginContainer/VBoxContainer/SpinBox
@onready var label: Label = $MarginContainer/VBoxContainer/LabelContainer/Label



func _ready() -> void:
	set_label_text(label_text)
	set_show_warning_bg(show_warning_bg)
	set_show_graident_bg(show_gradient_bg)
	set_disabled(disabled)
	
	set_gradient_top_color(graident_top_color)
	set_gradient_bottom_color(graident_bottom_color)
	
	set_max_value(max_value)
	set_value(value)
	set_reset_icon(reset_icon)
	
	set_show_randomise_button(show_randomise_button)
	
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
func set_gradient_top_color(color: Color) -> void:
	graident_top_color = color
	if is_node_ready(): $GraidentContainer/GraidentBG.get_theme_stylebox("panel").texture.gradient.set_color(1, color)


## Sets the bottom color of the graident
func set_gradient_bottom_color(color: Color) -> void:
	graident_bottom_color = color
	if is_node_ready(): $GraidentContainer/GraidentBG.get_theme_stylebox("panel").texture.gradient.set_color(0, color)


## Sets the max value of the slider
func set_max_value(p_max_value: int) -> void:
	max_value = p_max_value
	
	if is_node_ready():
		slider.max_value = max_value
		spin_box.max_value = max_value


## Sets the current value
func set_value(p_value: int) -> void:
	value = clamp(p_value, 0, max_value)
	
	if is_node_ready():
		slider.set_value_no_signal(p_value)
		spin_box.set_value_no_signal(p_value)


## Disabled or enables this slider
func set_disabled(p_disabled: bool) -> void:
	disabled = p_disabled
	
	if is_node_ready():
		slider.editable = not disabled
		spin_box.editable = not disabled
		$MarginContainer/VBoxContainer/HBoxContainer/Reset.disabled = disabled
		$MarginContainer/VBoxContainer/HBoxContainer/Random.disabled = disabled


func set_reset_icon(icon: Texture2D) -> void:
	reset_icon = icon
	if is_node_ready():
		$MarginContainer/VBoxContainer/HBoxContainer/Reset.icon = reset_icon


func set_show_randomise_button(p_show_randomise_button: bool) -> void:
	show_randomise_button = p_show_randomise_button
	if is_node_ready():
		$MarginContainer/VBoxContainer/HBoxContainer/Random.visible = show_randomise_button

## resets the value of the slider with out sending a message
func reset_no_message() -> void:
	value = 0
	show_override_warning(false)


## Sends the value message
func _send_set_value_message(value: int) -> void:
	
	if not send__set_command: 
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


func show_override_warning(show_warning: bool) -> void:
	if show_warning_bg:
		$WarningBG.visible = show_warning


## Called when the slider is moved
func _on_v_slider_value_changed(p_value: float) -> void:
	value = p_value
	
	show_override_warning(true)
	_send_set_value_message(value)
	
	value_changed.emit(value)


## Called when the input box is changed
func _on_spin_box_value_changed(p_value: float) -> void:
	value = p_value
	
	show_override_warning(true)
	_send_set_value_message(value)
	
	value_changed.emit(value)


## Called when the reset button is pressed
func _on_reset_pressed() -> void:
	reset_no_message()
	
	if send_reset_command: 
		Client.send({
			"for": object_id,
			"call": reset_method,
			"args": args_befour if not send_selection_value else args_befour + [Values.get_selection_value(send_selection_value, [])]
		})
	
	reset_pressed.emit()


## Called when the random button is pressed
func _on_random_pressed() -> void:
	show_override_warning(true)
	
	if send_randomise_command:
		Client.send_command(object_id, randomise_method, randomise_args if not send_selection_value else [Values.get_selection_value(send_selection_value, [])] + randomise_args)
	else:
		slider.value = randi_range(0, max_value)
	
	randomise_pressed.emit()

# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

@tool
class_name ChannelSlider extends PanelContainer
## The slider used for channel overrides

@export var object_id: String = ""
@export var method: String = ""
@export var reset_method: String = ""
@export var args_befour: Array = []
@export var args_after: Array = []
@export var label_text: String = "Slider": set = set_label_text
@export var send_selection_value: String = ""


func set_label_text(text: String):
	label_text = text
	
	if is_node_ready():
		$VBoxContainer/Label.text = text


func clear_no_message() -> void:
	$VBoxContainer/VSlider.set_value_no_signal(0)
	$VBoxContainer/SpinBox.set_value_no_signal(0)
	$WarningBG.hide()


func _ready() -> void:
	set_label_text(label_text)


func _send_set_value_message(value: int) -> void:
	
	var args: Array = []
	
	if send_selection_value:
		args_befour + Values.get_selection_value(send_selection_value, []) + [value] + args_after 
	else:
		args_befour + [value] + args_after 
	
	Client.send({
		"for": object_id,
		"call": method,
		"args": args
	})


func _on_v_slider_value_changed(value: float) -> void:
	$VBoxContainer/SpinBox.set_value_no_signal(value)
	$WarningBG.show()
	_send_set_value_message(value)


func _on_spin_box_value_changed(value: float) -> void:
	$VBoxContainer/VSlider.set_value_no_signal(value)
	$WarningBG.show()
	_send_set_value_message(value)


func _on_clear_pressed() -> void:
	clear_no_message()
	
	Client.send({
		"for": object_id,
		"call": reset_method,
		"args": args_befour if not send_selection_value else args_befour + Values.get_selection_value(send_selection_value, [])
	})

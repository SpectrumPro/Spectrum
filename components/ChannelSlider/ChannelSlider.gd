# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name ChannelSlider extends PanelContainer
## The slider used for channel overrides


var channel: int = 1 : set = set_channel
var universe_object_id: String = "programmer"


func set_channel(p_channel: int) -> void:
	channel = p_channel
	$"VBoxContainer/Channel Number".text = str(channel)


func clear_no_message() -> void:
	$VBoxContainer/VSlider.set_value_no_signal(0)
	$VBoxContainer/SpinBox.set_value_no_signal(0)


func _send_set_value_message(value: int) -> void:
	Client.send({
		"for": universe_object_id,
		"call": "set_dmx_override",
		"args": [channel, value]
	})


func _on_v_slider_value_changed(value: float) -> void:
	$VBoxContainer/SpinBox.set_value_no_signal(value)
	_send_set_value_message(value)


func _on_spin_box_value_changed(value: float) -> void:
	$VBoxContainer/VSlider.set_value_no_signal(value)
	_send_set_value_message(value)


func _on_clear_pressed() -> void:
	$VBoxContainer/VSlider.set_value_no_signal(0)
	$VBoxContainer/SpinBox.set_value_no_signal(0)
	
	Client.send({
		"for": universe_object_id,
		"call": "remove_dmx_override",
		"args": [channel]
	})

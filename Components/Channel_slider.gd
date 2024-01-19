extends Control

var callback
var id = 1

func _on_clear_button_down():
	$VBoxContainer/VSlider.value = 0

func _on_v_slider_value_changed(value):
	$VBoxContainer/SpinBox.set_value_no_signal(value)
	if callback:
		callback.call(value, id)

func _on_spin_box_value_changed(value):
	$VBoxContainer/VSlider.set_value_no_signal(value)
	if callback:
		callback.call(value, id)

func set_value(value):
	$VBoxContainer/SpinBox.set_value_no_signal(value)
	$VBoxContainer/VSlider.set_value_no_signal(value)

func set_channel_name(name):
	$VBoxContainer/Label.text = str(name)


extends Control

var callback
var id = 1

func _on_clear_button_down():
	$VBoxContainer/VSlider.value = 0

func _on_v_slider_value_changed(value):
	$VBoxContainer/SpinBox.value = value
	if callback:
		callback.call(value, id)

func set_channel_name(name):
	$VBoxContainer/Label.text = str(name)

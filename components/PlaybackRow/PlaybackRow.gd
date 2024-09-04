# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name PlaybackRowComponent extends MarginContainer
## The playback row container used in the playbacks panel

@onready var button1: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/Button1")
@onready var button2: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/Button2")
@onready var button3: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/Button3")
@onready var button4: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/Button4")
@onready var button5: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/Button5")

@onready var slider: VSlider = get_node("PanelContainer/MarginContainer/VBoxContainer/Slider")

## Sets the value of the slider, converting from 0-1 to 0-155
func set_slider_value(value: float) -> void:
	slider.set_value_no_signal(remap(value, 0.0, 1.0, 0, 255))

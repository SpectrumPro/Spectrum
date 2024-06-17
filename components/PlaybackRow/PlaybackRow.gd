# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends MarginContainer
## The playback row container used in the playbacks panel

@onready var button1: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/Button1")
@onready var button2: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/Button2")
@onready var button3: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/Button3")
@onready var button4: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/Button4")
@onready var button5: Button = get_node("PanelContainer/MarginContainer/VBoxContainer/Button5")

@onready var slider: VSlider = get_node("PanelContainer/MarginContainer/VBoxContainer/Slider")

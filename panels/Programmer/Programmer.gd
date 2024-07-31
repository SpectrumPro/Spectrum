# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name ProgrammerUI extends PanelContainer
## UI panel for programing scenes


@onready var all_mode_button: Button = $HBoxContainer/SaveControls/VBoxContainer/All
@onready var individual_mode_button: Button = $HBoxContainer/SaveControls/VBoxContainer/Individual


@onready var sliders: Array = [
	$HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/Dimmer/DimmerSlider,
	$HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/ColorSliders/HBoxContainer/Red,
	$HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/ColorSliders/HBoxContainer/Green,
	$HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/ColorSliders/HBoxContainer/Blue,
	$HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/ColorSliders/HBoxContainer/Hue,
	$HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/ColorSliders/HBoxContainer/Saturation,
	$HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/ColorSliders/HBoxContainer/Value,
	$HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/ExtraIntensityChannels/HBoxContainer/White,
	$HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/ExtraIntensityChannels/HBoxContainer/Amber,
	$HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/ExtraIntensityChannels/HBoxContainer/UV,
]


func _ready() -> void:
	var new_button_group: ButtonGroup = ButtonGroup.new()
	
	all_mode_button.button_group = new_button_group
	individual_mode_button.button_group = new_button_group
	
	new_button_group.allow_unpress = false
	new_button_group.pressed.connect(_on_button_group_button_pressed)


func _on_button_group_button_pressed(button: Button) -> void:
	_set_individual_mode(button == individual_mode_button)


func _set_individual_mode(individual_mode: bool) -> void:
	for slider: ChannelSlider in sliders:
		slider.send_randomise_command = individual_mode

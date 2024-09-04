# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name ProgrammerUI extends PanelContainer
## UI panel for programing scenes


@onready var all_mode_button: Button = $HBoxContainer/Controls/VBoxContainer/All
@onready var individual_mode_button: Button = $HBoxContainer/Controls/VBoxContainer/Individual


## Stores all the sliders or controllers for all the supported channels on fixtures
@onready var channel_controllers: Dictionary = {
	"Dimmer": $HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/Dimmer/DimmerSlider,
	"set_color": $HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem,
	"ColorIntensityWhite": $HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/ExtraIntensityChannels/HBoxContainer/White,
	"ColorIntensityAmber": $HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/ExtraIntensityChannels/HBoxContainer/Amber,
	"ColorIntensityUV": $HBoxContainer/TabContainer/Light/ScrollContainer/HBoxContainer/LevelControls/ColorSystem/ExtraIntensityChannels/HBoxContainer/UV,
}


func _ready() -> void:
	_create_button_group()
	
	Values.connect_to_selection_value("selected_fixtures", _on_fixture_selection_changed)

## Create the button group for the alland individual mode buttons 
func _create_button_group() -> void:
	var new_button_group: ButtonGroup = ButtonGroup.new()
	
	all_mode_button.button_group = new_button_group
	individual_mode_button.button_group = new_button_group
	
	new_button_group.allow_unpress = false
	new_button_group.pressed.connect(_on_button_group_button_pressed)


func _on_fixture_selection_changed(fixtures: Array) -> void:
	if fixtures:
		var fixture: Fixture = fixtures[0]
		
		for channel_key in fixture.current_values.keys():
			if channel_key in channel_controllers:
				channel_controllers[channel_key].set_value(fixture.current_values[channel_key])
				channel_controllers[channel_key].disabled = false
				
				if fixture.get_override_value_from_channel_key(channel_key) != null:
					channel_controllers[channel_key].show_override_warning(true)
	else:
		for channel_controller in channel_controllers.values():
			channel_controller.reset_no_message()
			channel_controller.disabled = true


func _on_button_group_button_pressed(button: Button) -> void:
	_set_individual_mode(button == individual_mode_button)


func _set_individual_mode(individual_mode: bool) -> void:
	for channel_controller in channel_controllers.values():
		channel_controller.send_randomise_command = individual_mode


func _on_locate_pressed() -> void:
	pass # Replace with function body.

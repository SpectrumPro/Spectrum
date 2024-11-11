# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name PlaybackRowComponent extends MarginContainer
## The playback row container used in the playbacks panel


## The buttons and sliders
@onready var button1: TriggerButton = get_node("PanelContainer/MarginContainer/VBoxContainer/Button1")
@onready var button2: TriggerButton = get_node("PanelContainer/MarginContainer/VBoxContainer/Button2")
@onready var button3: TriggerButton = get_node("PanelContainer/MarginContainer/VBoxContainer/Button3")
@onready var button4: TriggerButton = get_node("PanelContainer/MarginContainer/VBoxContainer/Button4")
@onready var button5: TriggerButton = get_node("PanelContainer/MarginContainer/VBoxContainer/Button5")
@onready var slider: TriggerSlider = get_node("PanelContainer/MarginContainer/VBoxContainer/Slider")


## Config for auto mode, will auto set up buttons and slider for differnt object types
@onready var auto_config: Dictionary = {
	"Scene": {
		button1: {
			"label": "Toggle", 
			"button_down": { "method_name": "set_enabled", "args": [true] },
			"button_up": { "method_name": "set_enabled", "args": [false] },
			"button_mode": TriggerButton.Mode.Toggle
		},
		button2: {
			"label": "Enable",
			"button_down": { "method_name": "set_enabled", "args": [true] },
		},
		button3: {
			"label": "Flash",
			"button_down": { "method_name": "flash_hold", "args": [0]},
			"button_up": { "method_name": "flash_release", },
		},
		button4: {
			"label": "Disable",
			"button_down": { "method_name": "set_enabled", "args": [false] },
		},
		button5: {"visible": false},
		slider: { 
			"trigger": { "method_name": "set_intensity" },
			"feedback": { "signal_name": "intensity_changed" }
		}
	},
	"CueList": {
		button1: {
			"label": "Play", 
			"button_down": { "method_name": "play" },
		},
		button2: {
			"label": "Pause",
			"button_down": { "method_name": "pause" },
		},
		button3: {
			"label": "Stop",
			"button_down": { "method_name": "stop"},
		},
		button4: {
			"label": "Go Previous",
			"button_down": { "method_name": "go_previous" },
		},
		button5: {
			"label": "Go Next",
			"button_down": { "method_name": "go_next" },
		},
		slider: { 
			"trigger": { "method_name": "set_intensity" },
			"feedback": { "signal_name": "intensity_changed" }
		}
	}
}


## Sets the value of the slider, converting from 0-1 to 0-155
func set_slider_value(value: float) -> void:
	slider.set_value_no_signal(remap(value, 0.0, 1.0, 0, 255))


## Sets the label text
func set_label(text: String) -> void:
	$PanelContainer/MarginContainer/VBoxContainer/Label.text = text


## Creates a dummy version of this playback row. Will copy all visual settings. Used in settings menues
func create_dummy_row() -> Control:
	return Interface.components.PlaybackRow.instantiate()


## Auto configures the buttons and slider for a component
func load_auto_config(component: EngineComponent) -> void:
	if component.self_class_name in auto_config:
		for trigger: Control in auto_config[component.self_class_name].keys():
			
			if trigger is TriggerButton:
				var button: TriggerButton = trigger
				var config: Dictionary = auto_config[component.self_class_name][button].duplicate(true)
				
				if config.get("button_down", ""): config.button_down.uuid = component.uuid
				if config.get("button_up", ""): config.button_up.uuid = component.uuid
				
				button.deserialize(config)
			
			if trigger is TriggerSlider:
				var slider: TriggerSlider = trigger
				var config: Dictionary = auto_config[component.self_class_name][slider].duplicate(true)
				
				if config.get("trigger", {}): config.trigger.uuid = component.uuid
				if config.get("feedback", {}): config.feedback.uuid = component.uuid
				
				slider.deserialize(config)
				
		
		set_label(component.name)

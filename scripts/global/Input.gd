# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name SpectrumInputServer extends Node
## Custem input manager for spectrum


## Midi Mappings based on the pitch value, {channel: {pitch: Mapping, ...}, ...}
var midi_pitch_mappings: Dictionary = {
	0: {
		9: InputTrigger.new().deseralize({
			"up": {"uuid": "eb92c15b-5c47-4688-8584-b40a8b83b7e9", "method_name": "intensity", "args": [0]},
			"down": {"uuid": "eb92c15b-5c47-4688-8584-b40a8b83b7e9", "method_name": "intensity", "args": [1]}
		}),
		10: InputTrigger.new().deseralize({
			"down": {"uuid": "c4c7069a-5db1-446b-8340-a5afd2418ced", "method_name": "flash", "args": [0, 0.3, 0.1]}
		}),
		11: InputTrigger.new().deseralize({
			"up": {"uuid": "6a07961e-d908-4c79-b43d-eee5abf5af43", "method_name": "intensity", "args": [0]},
			"down": {"uuid": "6a07961e-d908-4c79-b43d-eee5abf5af43", "method_name": "intensity", "args": [1]}
		}),
		12: InputTrigger.new().deseralize({
			"up": {"uuid": "bb3596a3-24ba-4b28-8269-5e7648c6289b", "method_name": "intensity", "args": [0]},
			"down": {"uuid": "bb3596a3-24ba-4b28-8269-5e7648c6289b", "method_name": "intensity", "args": [1]}
		}),
		28: InputTrigger.new().deseralize({
			"down": {"uuid": "c4c7069a-5db1-446b-8340-a5afd2418ced", "method_name": "flash", "args": [0, 0, 0.1]}
		}),
	}
}


## Midi Mappings based on the control number value, {channel: {control: Mapping, ...}, ...}
var midi_controler_mappings: Dictionary = {
	0: {
		41: InputTrigger.new().deseralize({
			"value": {"uuid": "eb92c15b-5c47-4688-8584-b40a8b83b7e9", "method_name": "global_pre_wait", "args": []},
			"value_config": {
				"remap": [0, 127, 0.003, 0.5]
			}
		}),
		43: InputTrigger.new().deseralize({
			"value": {"uuid": "6a07961e-d908-4c79-b43d-eee5abf5af43", "method_name": "global_pre_wait", "args": []},
			"value_config": {
				"remap": [0, 127, 0.003, 0.5]
			}
		}),
	}
}


func _ready() -> void:
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())


## Called for every InputEvent
func _input(event: InputEvent) -> void:
	if event is InputEventMIDI: 
		_handle_midi_input(event)
	
	if event.is_action_pressed("reload"):
		Client.connect_to_server()
	
	if Input.is_action_just_pressed("clear_programmer"): 
		Programmer.clear()


## Handles Midi input events
func _handle_midi_input(midi: InputEventMIDI) -> void:
	print(midi)
	if midi.channel in midi_pitch_mappings:
		match midi.message:
			MIDI_MESSAGE_NOTE_ON:
				if midi.pitch in midi_pitch_mappings[midi.channel]: 
					midi_pitch_mappings[midi.channel][midi.pitch].down()
			
			MIDI_MESSAGE_NOTE_OFF:
				if midi.pitch in midi_pitch_mappings[midi.channel]: 
					midi_pitch_mappings[midi.channel][midi.pitch].up()
			
			MIDI_MESSAGE_CONTROL_CHANGE:
				if midi.controller_number in midi_controler_mappings[midi.channel]:
					midi_controler_mappings[midi.channel][midi.controller_number].value(midi.controller_value)

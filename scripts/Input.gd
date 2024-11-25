# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name SpectrumInputServer extends Node
## Custem input manager for spectrum


## Midi Mappings, {channel: {pitch: Mapping, ...}, ...}
var midi_mappings: Dictionary = {
	0: {
		12: InputTrigger.new().deseralize({
			"up": {"uuid": "eb92c15b-5c47-4688-8584-b40a8b83b7e9", "method_name": "intensity", "args": [0]},
			"down": {"uuid": "eb92c15b-5c47-4688-8584-b40a8b83b7e9", "method_name": "intensity", "args": [1]}
		}),
		13: InputTrigger.new().deseralize({
			"down": {"uuid": "c4c7069a-5db1-446b-8340-a5afd2418ced", "method_name": "flash", "args": [0, 0.3, 0.1]}
		})
	}
}


func _ready() -> void:
	OS.open_midi_inputs()

## Called for every InputEvent
func _input(event: InputEvent) -> void:
	print(event)
	if event is InputEventMIDI: _handle_midi_input(event)


## Handles Midi input events
func _handle_midi_input(midi: InputEventMIDI) -> void:
	if midi.channel in midi_mappings:
		if midi.pitch in midi_mappings[midi.channel]:
			match midi.message:
				MIDI_MESSAGE_NOTE_ON:
					midi_mappings[midi.channel][midi.pitch].down()
				MIDI_MESSAGE_NOTE_OFF:
					midi_mappings[midi.channel][midi.pitch].up()

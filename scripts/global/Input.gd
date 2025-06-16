# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name SpectrumInputServer extends Node
## Custom input manager for Spectrum


## Midi Mappings based on the pitch value, {channel: {pitch: Mapping, ...}, ...}
var _midi_pitch_mappings: Dictionary = {}

## Midi Mappings based on the control number value, {channel: {control: Mapping, ...}, ...}
var _midi_controler_mappings: Dictionary = {}

## User defined actions
var _user_actions: Dictionary[String, ComponentTrigger] = {
	"Test": ComponentTrigger.new().deseralize({
		"component": "9971302f-5c61-42f6-bf40-4e4a2592391e",
		"up_method": "off",
		"down_method": "on",
	})
}

## Internal actions
var _internal_actions: Dictionary[String, Callable] = {
	"reload": Client.connect_to_server,
	"clear_programmer": Programmer.clear,
	"store_mode": _handle_store_mode_action

}

## Allowed input events for shortcuts
var _allowed_events: Array[String] = [
	"InputEventKey"
]


## Blocklist for keycodes
var _keycode_block_list: Array[Key] = [
	KEY_SPACE,
	KEY_ENTER,
	KEY_ESCAPE
]


func _ready() -> void:
	OS.open_midi_inputs()


## Called for every InputEvent
func _input(event: InputEvent) -> void:
	if event is InputEventMIDI: 
		_handle_midi_input(event)
	
	for action: String in _user_actions:
		if Input.is_action_just_pressed(action):
			_user_actions[action].down()
		
		if Input.is_action_just_released(action):
			_user_actions[action].up()
	
	for action: String in _internal_actions:
		if Input.is_action_just_released(action):
			_internal_actions[action].call()


## Checks if an event is allowed for shortcut inputs
func is_event_allowed(event: InputEvent) -> bool:
	return event.get_class() in _allowed_events


## Checks if a key is allowed
func is_key_allowed(key: Key) -> bool:
	return key not in _keycode_block_list


## Handles Midi input events
func _handle_midi_input(midi: InputEventMIDI) -> void:
	if midi.channel in _midi_pitch_mappings:
		match midi.message:
			MIDI_MESSAGE_NOTE_ON:
				if midi.pitch in _midi_pitch_mappings[midi.channel]: 
					_midi_pitch_mappings[midi.channel][midi.pitch].down()
			
			MIDI_MESSAGE_NOTE_OFF:
				if midi.pitch in _midi_pitch_mappings[midi.channel]: 
					_midi_pitch_mappings[midi.channel][midi.pitch].up()
			
			MIDI_MESSAGE_CONTROL_CHANGE:
				if midi.controller_number in _midi_controler_mappings[midi.channel]:
					_midi_controler_mappings[midi.channel][midi.controller_number].value(midi.controller_value)


## Handles the store mode action
func _handle_store_mode_action() -> void:
	Programmer.exit_store_mode() if Programmer.get_store_mode() else Programmer.enter_store_mode()

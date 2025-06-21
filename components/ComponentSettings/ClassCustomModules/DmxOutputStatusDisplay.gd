# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name DMXOutputStatusDisplay extends PanelContainer
## Custom status display for DMXOutput


## The ConnectionState label
@export var _status_label: Label = null


## Connected color
var _connected_color: Color = Color(0.32, 1, 0.32)

## Disconnected color
var _disconnected_color: Color = Color(1, 0.32, 0.32)

## The current DMXOutput
var _output: DMXOutput = null

## Signal connections for the DMXOutput
var _signal_connections: Dictionary = {"connection_state_changed": _on_connection_state_changed}


func _ready() -> void:
	add_theme_stylebox_override("panel", get_theme_stylebox("panel").duplicate())


## Sets the output
func set_output(output: DMXOutput) -> void:
	Utils.disconnect_signals(_signal_connections, _output)
	_output = output
	Utils.connect_signals(_signal_connections, _output)
	
	_on_connection_state_changed(_output.get_connection_state(), _output.get_previous_note())


## Called when the connection state changes on the DMXOutput
func _on_connection_state_changed(state: bool, note: String) -> void:
	_status_label.tooltip_text = note
	
	if state:
		#get_theme_stylebox("panel").bg_color = _connected_color
		_status_label.text = "CONNECTED"
		_status_label.label_settings.font_color = _connected_color
	
	else:
		#get_theme_stylebox("panel").bg_color = _disconnected_color
		_status_label.text = "DISCONNECTED"
		_status_label.label_settings.font_color = _disconnected_color
		

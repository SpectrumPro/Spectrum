# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name DMXOutputStatusDisplay extends PanelContainer
## Custom status display for DMXOutput


## The ConnectionState label
@export var status_label: Label = null


## The current DMXOutput
var _output: DMXOutput = null

## Signal group for DMXOutput
var _signal_group: SignalGroup = SignalGroup.new([
	_on_connection_state_changed
])


## ready
func _ready() -> void:
	status_label.label_settings = LabelSettings.new()
	status_label.label_settings.font = ThemeManager.Fonts.RubikMono


## Sets the output
func set_output(p_output: DMXOutput) -> void:
	_signal_group.disconnect_object(_output)
	_output = p_output
	_signal_group.connect_object(_output)
	
	_on_connection_state_changed(_output.get_connection_state(), _output.get_previous_note())


## Called when the connection state changes on the DMXOutput
func _on_connection_state_changed(state: bool, note: String) -> void:
	status_label.tooltip_text = note
	
	if state:
		status_label.text = "CONNECTED"
		status_label.label_settings.font_color = ThemeManager.Colors.Statuses.Normal
	
	else:
		status_label.text = "DISCONNECTED"
		status_label.label_settings.font_color = ThemeManager.Colors.Statuses.Off

# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UIPopupDialog extends UIPopup
## UIPopupDialog


## Emitted when the value is set
signal value_set(value: Variant)

## Emitted when the mode is changed
signal mode_changed(mode: Mode)


## Enum for dialog modes
enum Mode {
	NONE,					## No Mode
	CONFIRMATION,			## Confirmation Dialog
	DELETE_CONFIRMATION,	## Delete Confirmation
	STRING,					## String input
}

## The title button
@export var title_button: Button

## The LineEdit for Mode.String
@export var mode_string_input: LineEdit


## All nodes for each Mode
@onready var _mode_nodes: Dictionary[Mode, Array] = {
	Mode.NONE: 					[],
	Mode.CONFIRMATION:			[%ConfirmationContainer, %ConfirmationConfirm],
	Mode.DELETE_CONFIRMATION:	[%ConfirmationContainer, %DeleteConfirmationConfirm],
	Mode.STRING: 				[mode_string_input, %DataInputContainer]
}

## All labels
@onready var _labels: Array[Label] = [%DataInputLabel, %ConfirmationLabel]

## All confirmation buttons
@onready var _confirm_button: Array[Button] = [%ConfirmationConfirm, %DeleteConfirmationConfirm]


## Current Mode
var _mode: Mode = Mode.STRING


## Init
func _init() -> void:
	super._init()
	_set_class_name("UIPopupDialog")
	_custom_accepted_signal = value_set


## Sets the Mode
func set_mode(p_mode: Mode) -> void:
	if p_mode == _mode:
		return
	
	for node: Node in _mode_nodes[_mode]:
		node.hide()
	
	_mode = p_mode
	
	for node: Node in _mode_nodes[_mode]:
		node.show()
	
	mode_changed.emit()


## Sets the title text
func set_title_text(p_title_text: String) -> void:
	title_button.set_text(p_title_text)


## Sets the label text
func set_label_text(p_label_text: String) -> void:
	for label: Label in _labels:
		label.set_text(p_label_text)


## Sets the button text
func set_button_text(p_button_text: String) -> void:
	for button: Button in _confirm_button:
		button.set_text(p_button_text)


## Gets the current Mode
func get_mode() -> Mode:
	return _mode


## Gets the title text
func get_title_text() -> String:
	return title_button.get_text()


## Gets the label text
func get_label_text() -> String:
	return _labels[0].get_text()


## Gets the button text
func get_button_text() -> String:
	return _confirm_button[0].get_text()


## Confirms and outputs the value of this UIPopupDialog
func confirm() -> void:
	match _mode:
		Mode.STRING:
			accept(mode_string_input.get_text())
		
		Mode.CONFIRMATION, Mode.DELETE_CONFIRMATION:
			accept(null)
		_:
			cancel()


## Takes focus onto the input for the current mode
func focus() -> void:
	match _mode:
		Mode.STRING:
			mode_string_input.grab_focus()
		
		_:
			edit_controls.close_button.grab_focus()

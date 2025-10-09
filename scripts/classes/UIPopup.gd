# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UIPopup extends UIPanel
## Base class for panel popups


## Emitted when the action of this popup is accepted
signal accepted()

## Emitted when the action of this popup is canceled
signal canceled()


## The signal emitted when the actions is accepted
var _custom_accepted_signal: Signal = Signal()


## Init
func _init() -> void:
	super._init()
	
	_set_class_name("UIPopup")
	await ready
	
	if is_instance_valid(edit_controls):
		edit_controls.close_button.pressed.connect(
			func (): 
				canceled.emit()
		)


## Sets the accepted signal
func set_custom_accepted_signal(p_custom_accepted_signal: Signal) -> void:
	_custom_accepted_signal = p_custom_accepted_signal


## Gets the accepted signal
func get_custom_accepted_signal() -> Signal:
	return _custom_accepted_signal


## Gets the custom accepted signal, or the default if none is given
func get_custom_signal_or_default() -> Signal:
	if _custom_accepted_signal.is_null():
		return accepted
	else:
		return _custom_accepted_signal


## Accepts this popup action
func accept(arg: Variant) -> void:
	_custom_accepted_signal.emit(arg)
	accepted.emit()


## Canceles this popup action
func cancel() -> void:
	canceled.emit()

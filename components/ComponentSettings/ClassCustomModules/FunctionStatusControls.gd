# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name FunctionStatusControls extends PanelContainer
## Custom setting panel for function TransportState, and ActiveState controls


## The Disable Button
@export var _disable_button: Button

## The Enable Button
@export var _enable_button: Button

## The Backwards Button
@export var _backwards_button: Button

## The Pause Button
@export var _pause_button: Button

## The Forwards Button
@export var _forwards_button: Button


## The Function
var _function: Function


## Sets the function
func set_function(function: Function) -> void:
	_function = function
	
	function.active_state_changed.connect(_on_active_state_changed)
	function.transport_state_changed.connect(_on_transport_state_changed)
	
	_on_active_state_changed(function.get_active_state())
	_on_transport_state_changed(function.get_transport_state())


## Called when the ActiveState is changed
func _on_active_state_changed(active_state: Function.ActiveState) -> void:
	_disable_button.disabled = active_state == Function.ActiveState.DISABLED
	_enable_button.disabled = active_state == Function.ActiveState.ENABLED


## Called when the TransportState is changed
func _on_transport_state_changed(transport_state: Function.TransportState) -> void:
	_backwards_button.disabled = transport_state == Function.TransportState.BACKWARDS
	_pause_button.disabled = transport_state == Function.TransportState.PAUSED
	_forwards_button.disabled = transport_state == Function.TransportState.FORWARDS


## Called when the Disable button is pressed
func _on_disable_pressed() -> void:
	_function.set_active_state(Function.ActiveState.DISABLED)


## Called when the Enable button is predded
func _on_enable_pressed() -> void:
	_function.set_active_state(Function.ActiveState.ENABLED)


## Called when the Backwards button is pressed
func _on_backwards_pressed() -> void:
	_function.set_transport_state(Function.TransportState.BACKWARDS)


## Called when the Paused button is pressed
func _on_pause_pressed() -> void:
	_function.set_transport_state(Function.TransportState.PAUSED)


## Called when the Fowards button is pressed
func _on_forwards_pressed() -> void:
	_function.set_transport_state(Function.TransportState.FORWARDS)

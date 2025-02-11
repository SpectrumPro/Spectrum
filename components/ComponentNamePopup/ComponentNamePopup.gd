# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name NamePickerComponent extends PanelContainer
## Simple ui component to change the name of an EngineComponent


## Emitted when the component is renamed
signal component_renamed(new_name: String)

## Emitted when the cancel button is pressed
signal canceled()


## The EngineComponent
var _component: EngineComponent = null

## Component signal connections
var _component_signal_connections: Dictionary = {
	"name_changed": _on_component_name_changed
}


## Sets the component
func set_component(p_component: EngineComponent) -> void:
	Utils.disconnect_signals(_component_signal_connections, _component)
	_component = p_component
	$HBox/LineEdit.text = _component.name
	Utils.connect_signals(_component_signal_connections, _component)


## Takes focus
func focus() -> void:
	$HBox/LineEdit.grab_focus()


## Sets the name
func _set_name() -> void:
	_component.set_name($HBox/LineEdit.text)
	component_renamed.emit($HBox/LineEdit.text)


## Called when the component's name changes
func _on_component_name_changed(new_name) -> void:
	$HBox/LineEdit.text = new_name
	$HBox/LineEdit.select_all()


## Called when the confirm button is pressed
func _on_confirm_pressed() -> void: _set_name()

## Called when the line edit has enter key pressed
func _on_line_edit_text_submitted(new_text: String) -> void: _set_name()

## Called when the cancel button is pressed
func _on_cancel_pressed() -> void: canceled.emit()

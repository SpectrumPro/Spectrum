# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name NamePickerComponent extends PanelContainer
## Simple ui component to change the name of an EngineComponent


## Emitted when the component is renamed
signal component_renamed(new_name: String)

## Emitted when the cancel button is pressed
signal canceled()


## The EngineComponent
var component: EngineComponent = null : set = set_component

## Auto hides this node when the name is confirmed
@export var auto_hide: bool = false


## Sets the component
func set_component(p_component: EngineComponent) -> void:
	if is_instance_valid(component): component.name_changed.disconnect(_on_component_name_changed)
	
	component = p_component
	$HBox/LineEdit.text = component.name
	
	component.name_changed.connect(_on_component_name_changed)


## Takes focus
func focus() -> void:
	$HBox/LineEdit.grab_focus()


## Sets the name
func _set_name() -> void:
	if is_instance_valid(component):
		component.set_name($HBox/LineEdit.text)
	
	if auto_hide:
		hide()
	
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
func _on_cancel_pressed() -> void: 
	if auto_hide: hide()
	canceled.emit()

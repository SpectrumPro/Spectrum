# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UIPad extends UIPanel
## A Pad for controlling differnt effects in each corner


## The top left method button in settings
@export var top_left_method_button: Button

## The top right method button in settings
@export var top_right_method_button: Button


## The top left label
@export var top_left_label: Label

## The top right label
@export var top_right_label: Label


## The cursor
@export var cursor: TextureRect

## The settings panel
@export var settings_node: Control

## The method picker
@export var method_picker: ComponentMethodPicker


## Trigger for the top left side
var top_left_trigger: MethodTrigger = MethodTrigger.new()

## Trigger for the top right side
var top_right_trigger: MethodTrigger = MethodTrigger.new()


## The last X Percentage
var _previous_x_percentage: float = 0

## The last Y Percentage
var _previous_y_percentage: float = 0


func _ready() -> void:
	remove_child(settings_node)
	remove_child(method_picker)
	Interface.add_root_child(method_picker)


func set_top_left_trigger(p_top_left_trigger: MethodTrigger) -> void:
	top_left_trigger = p_top_left_trigger
	top_left_method_button.text = p_top_left_trigger.get_as_string()
	#top_left_label.text = p_top_left_trigger.get_component().name


func set_top_right_trigger(p_top_right_trigger: MethodTrigger) -> void:
	top_right_trigger = p_top_right_trigger
	top_right_method_button.text = p_top_right_trigger.get_as_string()
	#top_right_label.text = p_top_right_trigger.get_component().name


func _update_triggers(p_position) -> void:
	var x_percentage: float = clampf(snappedf(p_position.x / size.x, 0.001), 0, 1)
	var y_percentage: float = 1 - clampf(snappedf(p_position.y / size.y, 0.001), 0, 1)
	
	print("X: ", 1 - x_percentage)
	print("Y: ", y_percentage)
	
	if top_left_trigger:
		top_left_trigger.args = [(1 - x_percentage) * y_percentage]
		top_left_trigger.call_method()
	
	if top_right_trigger:
		top_right_trigger.args = [x_percentage * y_percentage]
		top_right_trigger.call_method()


func _update_cursor_position(p_position: Vector2) -> void:
	var pos2: Vector2 = Vector2.ZERO
	
	pos2.x = clamp(p_position.x - cursor.size.x / 2, 0, size.x - cursor.size.x)
	pos2.y = clamp(p_position.y - cursor.size.y / 2, 0, size.y - cursor.size.y)
	
	cursor.position = pos2


func _on_panel_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
		_update_triggers(event.position)
		_update_cursor_position(event.position)


func _on_top_left_method_button_pressed() -> void:
	method_picker.set_method_config(top_left_trigger)
	method_picker.method_confired.connect(_on_top_left_method_chosen, CONNECT_ONE_SHOT)
	method_picker.show()


func _on_top_left_method_chosen(method_trigger: MethodTrigger) -> void:
	set_top_left_trigger(method_trigger)
	method_picker.hide()


func _on_top_right_method_button_pressed() -> void:
	method_picker.set_method_config(top_right_trigger)
	method_picker.method_confired.connect(_on_top_right_method_chosen, CONNECT_ONE_SHOT)
	method_picker.show()


func _on_top_right_method_chosen(method_trigger: MethodTrigger):
	set_top_right_trigger(method_trigger)
	method_picker.hide()


func _on_component_method_picker_cancled() -> void:
	if method_picker.method_confired.is_connected(_on_top_left_method_chosen):
		method_picker.method_confired.disconnect(_on_top_left_method_chosen)
	
	if method_picker.method_confired.is_connected(_on_top_right_method_chosen):
		method_picker.method_confired.disconnect(_on_top_right_method_chosen)
		
	method_picker.hide()


func save() -> Dictionary:
	return {
		"top_left": top_left_trigger.seralize(),
		"top_right": top_right_trigger.seralize()
	}


func load(saved_data: Dictionary) -> void:
	if saved_data.get("top_left") is Dictionary: 
		top_left_trigger.deseralize(saved_data.top_left)
		set_top_left_trigger(top_left_trigger)
		
	if saved_data.get("top_right") is Dictionary: 
		top_right_trigger.deseralize(saved_data.top_right)
		set_top_right_trigger(top_right_trigger)

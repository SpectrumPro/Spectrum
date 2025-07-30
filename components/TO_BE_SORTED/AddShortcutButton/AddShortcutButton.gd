# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

@tool

class_name AddShortcutButton extends Control
## UI button for asigning a shortcut other BaseButton nodes


## Emitted when the shortcut is changed
signal shortcut_changed(input_event: InputEvent)


## The BaseButton node this AddShortcutButton controls
var button: BaseButton = null : set = set_button

## The InputEvent
var event: InputEvent = null : set = set_event

## Wether or not to listen to inputs
var listning: bool = false : set = set_listning


## The text of the label
@export var label_text: String = "Label" : set = set_label_text

## The icon of the button
@export var button_icon: Texture2D = null : set = set_button_icon

## Defines if the InputEvent needs to be the release action to trigger
@export var unpress_required: bool = true


## The button node
@onready var _toggle_button: Button = $HBoxContainer/Button


## InputEvent's that are not allowed as shortcuts
var _not_allowed_events: Array = [
	"InputEventMouse", 
	"InputEventGesture", 
	"InputEventMouseMotion", 
	"InputEventMouseButton", 
	"InputEventPanGesture", 
	"InputEventMagnifyGesture", 
	"InputEventScreenTouch", 
	"InputEventScreenDrag"
]


func _ready() -> void:
	set_label_text(label_text)
	set_button_icon(button_icon)


## Sets the button to control
func set_button(p_buton: BaseButton) -> void:
	button = p_buton


## Sets the InputEvent
func set_event(p_event: InputEvent) -> void:
	event = p_event
	var new_shortcut: Shortcut = Shortcut.new()
	
	if event:
		_toggle_button.text = event.as_text()
		new_shortcut.events.append(event)
	else:
		_toggle_button.text = "Unassigned"
		new_shortcut = null
	
	if is_instance_valid(button):
		button.shortcut = new_shortcut
	
	set_listning(false)


func set_listning(p_listning: bool) -> void:
	listning = p_listning
	if p_listning:
		_toggle_button.button_pressed = true
		_toggle_button.gui_input.connect(_on_gui_input)
	else:
		_toggle_button.button_pressed = false
		
		if _toggle_button.gui_input.is_connected(_on_gui_input):
			_toggle_button.gui_input.disconnect(_on_gui_input)


func set_label_text(p_label_text: String) -> void:
	label_text = p_label_text
	
	if is_node_ready():
		$HBoxContainer/Label.text = label_text
		$HBoxContainer/Label.visible = label_text != ""


func set_button_icon(p_button_icon: Texture2D) -> void:
	button_icon = p_button_icon
	
	if is_node_ready():
		_toggle_button.icon = button_icon


## Serializes the InputEvent so it can be loaded again later
func save() -> Dictionary:
	return {"input_event": var_to_str(event)}


## Loads a serialized InputEvent, and asignes it to the button
func load(serialized_data: Dictionary) -> void:
	if "input_event" in serialized_data:
		var input_event: Variant = str_to_var(serialized_data.input_event)
		
		if input_event is InputEvent:
			set_event(input_event)


## Called when a gui input has happened
func _on_gui_input(p_event: InputEvent) -> void:
	if not p_event.get_class() in _not_allowed_events and (p_event.is_released() or not unpress_required):
		if p_event is InputEventKey:
			match p_event.keycode:
				KEY_BACKSPACE:
					set_listning(false)
					set_event(null)
				
				KEY_ESCAPE:
					set_listning(false)
				_:
					set_event(p_event)
					shortcut_changed.emit(event)
				
		else:
			set_event(p_event)
			shortcut_changed.emit(event)


## Called when the button is pressed
func _on_button_toggled(toggled_on: bool) -> void:
	set_listning(toggled_on)

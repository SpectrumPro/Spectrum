# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

@tool

class_name AddShortcutButton extends Control
## UI button for asigning a shortcut other BaseButton nodes


## Emitted when the shortcut is changed
signal on_shortcut_changed(input_event:InputEvent)


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


func _ready() -> void:
	set_label_text(label_text)
	set_button_icon(button_icon)


## Sets the button to control
func set_button(p_buton: BaseButton) -> void:
	button = p_buton


## Sets the InputEvent
func set_event(p_event: InputEvent) -> void:
	event = p_event
	_toggle_button.text = OS.get_keycode_string(event.get_keycode_with_modifiers())
	
	if button:
		var new_shortcut: Shortcut = Shortcut.new()
		new_shortcut.events.append(event)
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
	if p_event is InputEventKey and (p_event.is_released() or not unpress_required):
		set_event(p_event)
		
		on_shortcut_changed.emit(event)


## Called when the button is pressed
func _on_button_toggled(toggled_on: bool) -> void:
	set_listning(toggled_on)

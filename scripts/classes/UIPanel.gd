# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UIPanel extends Control
## Base class for all UI Panels


## Emitted when the panel requests to be moved when not in edit mode, by is the distance
signal request_move(by: Vector2)

## Emitted when the panel requests to be resized when not in edit mode, to is the new size
signal request_resize(by: Vector2)

## Emitted when the edit mode is toggled
signal edit_mode_toggled(state: bool)

## Emitted when the close button is pressed
signal close_request()


## The move and resize handle, used by UIPanel
@export var edit_controls: UIPanelEditControls = null : set = set_edit_controls

## The panel's settings node
@export var settings_node: Control = null : set = set_settings_node

## All the nodes whos visibility should be toggled with edit mode
@export var edit_mode_nodes: Array[Control] = []


## Display mode for this panel
enum DisplayMode {Panel, Popup}

## The current settigns node, if any
var _settings_node: Control = null

## Edit mode state
var edit_mode: bool = false : set = set_edit_mode

## Edit mode disabled state
var _edit_mode_disabled: bool = false



func _init() -> void:
	set_edit_mode.call_deferred(false)


## Sets the move and resize handle
func set_edit_controls(node: UIPanelEditControls) -> void:
	if is_instance_valid(edit_controls): 
		edit_controls.move_resize_handle.gui_input.disconnect(_on_move_resize_gui_input)
		edit_controls.edit_button.toggled.disconnect(_on_edit_button_toggled)
		edit_controls.settings_button.toggled.disconnect(_on_settings_button_toggled)
		edit_controls.close_button.pressed.disconnect(_on_close_button_pressed)
		edit_controls = null
	
	if node:
		edit_controls = node
		edit_controls.move_resize_handle.gui_input.connect(_on_move_resize_gui_input)
		edit_controls.edit_button.toggled.connect(_on_edit_button_toggled)
		edit_controls.settings_button.toggled.connect(_on_settings_button_toggled)
		edit_controls.close_button.pressed.connect(_on_close_button_pressed)


## Sets the settings node
func set_settings_node(node: Control) -> void:
	if is_instance_valid(_settings_node):
		Interface.remove_custom_popup(_settings_node)
		_settings_node = null
	
	if is_instance_valid(node):
		_settings_node = node
		_settings_node.get_parent_control().remove_child(_settings_node)
		_settings_node.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		
		Interface.add_custom_popup(_settings_node)
		
		if is_instance_valid(edit_controls):
			edit_controls.settings_button.disabled = false


## Sets the display mode
func set_display_mode(mode: DisplayMode) -> void:
	if not is_instance_valid(edit_controls):
		return 
	
	edit_controls.close_button.visible = (mode == DisplayMode.Popup)


## Sets the edit mode state
func set_edit_mode(state: bool) -> void:
	edit_mode = state
	
	for control: Control in edit_mode_nodes:
		control.visible = state
	
	_edit_mode_toggled(edit_mode)
	edit_mode_toggled.emit(edit_mode)


## Gets the edit mode state
func get_edit_mode() -> bool:
	return edit_mode


## Override this function to change state when edit mode is toggled
func _edit_mode_toggled(state: bool) -> void:
	pass


## Shows or hides the panels settings
func set_show_settings(show_settings: bool) -> void:
	if not is_instance_valid(_settings_node):
		return
	
	if show_settings:
		Interface.show_custom_popup(_settings_node)
	else:
		Interface.hide_custom_popup(_settings_node)


## Disables or enabled edit mode
func set_edit_mode_disabled(disabled: bool) -> void:
	if edit_mode:
		set_edit_mode(false)
	
	_edit_mode_disabled = disabled
	
	if is_instance_valid(edit_controls):
		edit_controls.edit_button.disabled = _edit_mode_disabled


## Disables all the buttons in the given array
func disable_button_array(buttons: Array[Button]) -> void:
	for button: Button in buttons:
		button.disabled = true


## Enables all the buttons in the given array
func enable_button_array(buttons: Array[Button]) -> void:
	for button: Button in buttons:
		button.disabled = false


## Called for GUI inputs on the move resize handle
func _on_move_resize_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		event = event as InputEventMouseMotion
		match event.button_mask:
			MOUSE_BUTTON_MASK_LEFT:
				request_move.emit(event.screen_relative)
			
			MOUSE_BUTTON_MASK_RIGHT:
				request_resize.emit(event.screen_relative)


## Called when the edit mode button is toggled
func _on_edit_button_toggled(state: bool) -> void:
	set_edit_mode(state)


## Called when the settings button is toggled
func _on_settings_button_toggled(state: bool) -> void:
	set_show_settings(state)


## Called when the close button is pressed
func _on_close_button_pressed() -> void:
	close_request.emit()


func save() -> Dictionary: return _save()
func _save() -> Dictionary: return {}

func load(saved_data: Dictionary) -> void: _load(saved_data)
func _load(saved_data: Dictionary) -> void: pass

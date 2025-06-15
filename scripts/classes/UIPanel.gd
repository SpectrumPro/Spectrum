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
@export var settings_node: Control = null

## All the nodes whos visibility should be toggled with edit mode
@export var edit_mode_nodes: Array[Control] = []

## All buttons that can have a shortcut asigned to them
@export var buttons: Array[Button]


## Display mode for this panel
enum DisplayMode {Panel, Popup}


## Edit mode state
var _edit_mode: bool = false

## Edit mode disabled state
var _edit_mode_disabled: bool = false

## RefMap for Button: ButtonName
var _buttons_map: RefMap = RefMap.new()

## Display mode for this panel
var _display_mode: DisplayMode = DisplayMode.Panel

## Mouse warp distance
var _mouse_warp: Vector2


func _init() -> void:
	set_edit_mode.call_deferred(false)
	
	await ready
	set_settings_node(settings_node)
	
	for button: Button in buttons:
		_buttons_map.map(button, button.name)


## Sets the move and resize handle
func set_edit_controls(p_edit_controls: UIPanelEditControls) -> void:
	if is_instance_valid(edit_controls): 
		edit_controls.move_resize_handle.gui_input.disconnect(_on_move_resize_gui_input)
		edit_controls.edit_button.toggled.disconnect(_on_edit_button_toggled)
		edit_controls.settings_button.pressed.disconnect(_on_settings_button_pressed)
		edit_controls.close_button.pressed.disconnect(_on_close_button_pressed)
	
	edit_controls = p_edit_controls
	
	if edit_controls:
		edit_controls.move_resize_handle.gui_input.connect(_on_move_resize_gui_input)
		edit_controls.edit_button.toggled.connect(_on_edit_button_toggled)
		edit_controls.settings_button.pressed.connect(_on_settings_button_pressed)
		edit_controls.close_button.pressed.connect(_on_close_button_pressed)
		
		edit_controls.settings_button.visible = edit_controls.show_settings
		edit_controls.edit_button.visible = edit_controls.show_edit
		edit_controls.close_button.visible = edit_controls.show_close


## Sets the settings node
func set_settings_node(node: Control) -> void:
	if is_instance_valid(settings_node):
		Interface.remove_custom_popup(settings_node)
		settings_node = null
	
	if is_instance_valid(node):
		settings_node = node
		settings_node.get_parent_control().remove_child(settings_node)
		settings_node.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		
		Interface.add_custom_popup(settings_node)
		
		if is_instance_valid(edit_controls):
			edit_controls.settings_button.disabled = false


## Sets the display mode
func set_display_mode(mode: DisplayMode) -> void:
	_display_mode = mode
	
	if is_instance_valid(edit_controls):
		edit_controls.close_button.visible = (mode == DisplayMode.Popup)


## Sets the edit mode state
func set_edit_mode(state: bool) -> void:
	_edit_mode = state
	
	for control: Control in edit_mode_nodes:
		control.visible = state
	
	_edit_mode_toggled(_edit_mode)
	edit_mode_toggled.emit(_edit_mode)


## Gets the edit mode state
func get_edit_mode() -> bool:
	return _edit_mode


## Override this function to change state when edit mode is toggled
func _edit_mode_toggled(state: bool) -> void:
	pass


## Shows or hides the panels settings
func show_settings() -> void:
	Interface.show_panel_settings(self)


## Disables or enabled edit mode
func set_edit_mode_disabled(disabled: bool) -> void:
	if _edit_mode:
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
		var relative: Vector2 = event.screen_relative - _mouse_warp
		_mouse_warp = Vector2.ZERO
		match event.button_mask:
			MOUSE_BUTTON_MASK_LEFT:
				request_move.emit(relative)
				if _display_mode == DisplayMode.Popup:
					position.x = clamp(position.x + relative.x, 0, get_parent_control().size.x - size.x)
					position.y = clamp(position.y + relative.y, 0, get_parent_control().size.y - size.y)
			
			MOUSE_BUTTON_MASK_RIGHT:
				request_resize.emit(relative)
				if _display_mode == DisplayMode.Popup:
					size.x = clamp(size.x + relative.x, 0, get_parent_control().size.x - position.x)
					size.y = clamp(size.y + relative.y, 0, get_parent_control().size.y - position.y)
					
					var gp: Vector2 = get_global_mouse_position()
					if gp.y <= 0:
						_mouse_warp = Vector2(0, edit_controls.move_resize_handle.global_position.y)
						Input.warp_mouse(Vector2(gp.x, _mouse_warp.y))


## Called when the edit mode button is toggled
func _on_edit_button_toggled(state: bool) -> void:
	set_edit_mode(state)


## Called when the settings button is toggled
func _on_settings_button_pressed() -> void:
	show_settings()


## Called when the close button is pressed
func _on_close_button_pressed() -> void:
	close_request.emit()


## Saves this UIPanel into a dictonary
func save() -> Dictionary:
	var seralized_buttons: Dictionary[String, String]
	
	for button: Button in buttons:
		if button.shortcut:
			seralized_buttons[button.name] = var_to_str(button.shortcut)
	
	return _save().merged({
		"button_shortcuts": seralized_buttons
	})


## Override to provide save function to your panel
func _save() -> Dictionary: 
	return {}


## Loads this UIPanel from dictionary
func load(saved_data: Dictionary) -> void: 
	var seralized_buttons: Variant = type_convert(saved_data.get("button_shortcuts", {}), TYPE_DICTIONARY)
	
	for button_name: Variant in seralized_buttons:
		if button_name is String and _buttons_map.has_right(button_name):
			var shortcut: Variant = str_to_var(seralized_buttons[button_name])
			if shortcut is Shortcut:
				_buttons_map.right(button_name).shortcut = shortcut
	
	_load(saved_data)


## Override to provide load function to your panel
func _load(saved_data: Dictionary) -> void: 
	pass

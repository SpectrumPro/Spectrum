# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UIPanel extends UIBase
## Base class for all UI Panels


## Emitted when the panel requests to be moved when not in edit mode, by is the distance
signal request_move(by: Vector2)

## Emitted when the panel requests to be resized when not in edit mode, to is the new size
signal request_resize(by: Vector2)

## Emitted when the edit mode is toggled
signal edit_mode_toggled(state: bool)

## Emitted when the close button is pressed
signal close_request()


## Display mode for this panel
@export var display_mode: DisplayMode = DisplayMode.Panel : set = set_display_mode

## The move and resize handle, used by UIPanel
@export var edit_controls: UIPanelEditControls = null : set = set_edit_controls

## All the nodes whos visibility should be toggled with edit mode
@export var edit_mode_nodes: Array[Control] = []

## All buttons that can have a shortcut asigned to them
@export var buttons: Array[Button]

## The menu mar
@export var menu_bar: PanelMenuBar


## Display mode for this panel
enum DisplayMode {Panel, Popup}


## Edit mode state
var _edit_mode: bool = false

## Edit mode disabled state
var _edit_mode_disabled: bool = false

## RefMap for Button: ButtonName
var _buttons_map: RefMap = RefMap.new()

## Stores all buttons and thier InputAction connections
var _button_actions: Dictionary[Button, Array]


## Mouse warp distance
var _mouse_warp: Vector2


## Init
func _init() -> void:
	_set_class_name("UIPanel")
	
	await ready
	set_edit_mode(false)
	for button: Button in buttons:
		_buttons_map.map(button, button.name)
		_button_actions[button] = []


## Disables all the buttons in the given array
static func disable_button_array(buttons: Array[Button]) -> void:
	for button: Button in buttons:
		button.disabled = true


## Enables all the buttons in the given array
static func enable_button_array(buttons: Array[Button]) -> void:
	for button: Button in buttons:
		button.disabled = false


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


## Sets the display mode
func set_display_mode(p_dispaly_mode: DisplayMode) -> void:
	display_mode = p_dispaly_mode
	
	if is_instance_valid(edit_controls):
		edit_controls.close_button.visible = (p_dispaly_mode == DisplayMode.Popup)
	
	print(ThemeManager.StyleBoxes.UIPanelPopup if (p_dispaly_mode == DisplayMode.Popup) else ThemeManager.StyleBoxes.UIPanelBase)
	add_theme_stylebox_override("panel", ThemeManager.StyleBoxes.UIPanelPopup if (p_dispaly_mode == DisplayMode.Popup) else ThemeManager.StyleBoxes.UIPanelBase)


## Sets the edit mode state
func set_edit_mode(state: bool) -> void:
	_edit_mode = state
	
	for control: Control in edit_mode_nodes:
		Interface.set_visible_and_fade(control, state)
	
	_edit_mode_toggled(_edit_mode)
	edit_mode_toggled.emit(_edit_mode)


## Disables or enabled edit mode
func set_edit_mode_disabled(disabled: bool) -> void:
	if _edit_mode:
		set_edit_mode(false)
	
	_edit_mode_disabled = disabled
	
	if is_instance_valid(edit_controls):
		edit_controls.edit_button.disabled = _edit_mode_disabled


## Gets the current DisplayMode
func get_display_mode() -> DisplayMode:
	return display_mode


## Gets the edit mode state
func get_edit_mode() -> bool:
	return _edit_mode


## Gets the EditMode disabled state
func get_edit_mode_disabled() -> bool:
	return _edit_mode_disabled


## Sets the menu bar visable state
func set_menu_bar_visable(p_visable: bool) -> void:
	if menu_bar:
		menu_bar.visible = p_visable


## Shows or hides the panels settings
func show_settings() -> void:
	Interface.show_panel_settings(self)


## Detaches the menu bar
func detatch_menu_bar() -> PanelMenuBar:
	if not is_instance_valid(menu_bar):
		return null
	
	menu_bar.set_popup_style(true)
	menu_bar.get_parent().remove_child(menu_bar)
	return menu_bar


## Adds a button to allow shortcuts to be added
func add_button(button: Button) -> bool:
	if _buttons_map.has_left(button):
		return false
	
	_buttons_map.map(button, button.name)
	_button_actions[button] = []
	return true


## Removes a button
func remove_button(button: Button) -> bool:
	if not _buttons_map.has_left(button):
		return false
	
	remove_all_button_actions(button)
	_buttons_map.erase_left(button)
	_button_actions.erase(button)
	
	return true


## Gets all the buttons
func get_buttons() -> Array:
	return _buttons_map.get_left()


## Asigned an InputAction to a button
func asign_button_action(button: Button, action: InputAction) -> bool:
	if button not in _button_actions or _button_actions[button].has(action):
		return false
	
	if action.connect_button(button):
		_button_actions[button].append(action)
		return true
	
	else:
		return false


## Asigned an InputAction to a button
func remove_button_action(button: Button, action: InputAction) -> bool:
	if button not in _button_actions or not _button_actions[button].has(action):
		return false
	
	_button_actions[button].erase(action)
	return action.disconnect_button(button)


## Removes all the actions from a button
func remove_all_button_actions(button: Button) -> bool:
	if button not in _button_actions:
		return false
	
	for action: InputAction in _button_actions[button]:
		action.disconnect_button(button)
	
	return true


## Gets all the InputActions asigned to a button
func get_button_actions(button: Button) -> Array:
	return _button_actions.get(button, [])


## Saves this UIPanel into a dictonary
func save() -> Dictionary:
	var button_actions: Dictionary[String, Array]
	
	for button: Button in _buttons_map.get_left():
		var actions: Array[String]
		for action: InputAction in get_button_actions(button):
			actions.append(action.uuid())
		
		button_actions[button.name] = actions
	
	return _save().merged({
		"button_actions": button_actions
	})


## Loads this UIPanel from dictionary
func load(saved_data: Dictionary) -> void: 
	_load(saved_data)
	
	var button_actions: Dictionary = type_convert(saved_data.get("button_actions"), TYPE_DICTIONARY)
	
	for button_name: Variant in button_actions.keys():
		if button_name is String and _buttons_map.has_right(button_name) and button_actions[button_name] is Array:
			for action_uuid: Variant in button_actions[button_name]:
				if action_uuid is String:
					var button: Button = _buttons_map.right(button_name)
					var action: InputAction = InputServer.get_input_action(action_uuid)
					
					if action:
						asign_button_action(button, action)


## Override this function to change state when edit mode is toggled
func _edit_mode_toggled(state: bool) -> void:
	pass


## Override to provide save function to your panel
func _save() -> Dictionary: 
	return {}


## Override to provide load function to your panel
func _load(saved_data: Dictionary) -> void: 
	pass


## Called for GUI inputs on the move resize handle
func _on_move_resize_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		event = event as InputEventMouseMotion
		var relative: Vector2 = event.screen_relative - _mouse_warp
		_mouse_warp = Vector2.ZERO
		match event.button_mask:
			MOUSE_BUTTON_MASK_LEFT:
				request_move.emit(relative)
				if display_mode == DisplayMode.Popup:
					position.x = clamp(position.x + relative.x, 0, get_parent_control().size.x - size.x)
					position.y = clamp(position.y + relative.y, 0, get_parent_control().size.y - size.y)
			
			MOUSE_BUTTON_MASK_RIGHT:
				request_resize.emit(relative)
				if display_mode == DisplayMode.Popup:
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

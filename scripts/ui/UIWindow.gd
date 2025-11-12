# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UIWindow extends Window
## Script for each window


## Called when the window title is changed
signal window_title_changed(window_title: String)

## Emitted when the base panel is changed
signal base_panel_changed(panel: UIPanel)

## Emitted when the DisplayMode is changed
signal display_mode_changed(diaplay_mode: DisplayMode)

## Emitted when the window position is changed
signal window_position_changed(window_position)

## Emitted when the window size is changed
signal window_size_changed(window_size: Vector2i)

## Emitted when the window borderless state is changed
signal window_borderless_changed(window_borderless)


## Enum for DisplayMode
enum DisplayMode {WINDOWED, MAXIMIZED, FULLSCREEN}


## The SettingsManager for this UIWindow
var settings_manager: SettingsManager = SettingsManager.new()

## The base UIPanel
var _base_panel: UIPanel

## DisplayMode
var _display_mode: DisplayMode = DisplayMode.WINDOWED

## The Control node that contains all window popups
var _window_popups: Control

## Previous size
var _previous_size: Vector2i

## Previous position
var _previous_pos: Vector2i


## Init
func _init() -> void:
	print(DisplayServer.get_name())
	settings_manager.set_owner(self)
	settings_manager.set_inheritance_array(["UIWindow"])
	
	settings_manager.register_setting("title", Data.Type.STRING, set_window_title, get_window_title, [window_title_changed])\
	.display("UIWindow", 0)
	
	settings_manager.register_setting("base_panel", Data.Type.UIPANEL, set_base_panel, get_base_panel, [base_panel_changed])\
	.display("UIWindow", 1).set_edit_condition(func(): return not is_window_root())
	
	settings_manager.register_setting("display_mode", Data.Type.ENUM, set_display_mode, get_display_mode, [display_mode_changed])\
	.display("UIWindow", 2).set_enum_dict(DisplayMode)
	
	settings_manager.register_setting("position", Data.Type.VECTOR2I, set_window_position, get_window_position, [window_position_changed])\
	.display("UIWindow", 3).set_min_max(Vector2.ZERO, Vector2.INF)
	
	settings_manager.register_setting("size", Data.Type.VECTOR2I, set_window_size, get_window_size, [window_size_changed])\
	.display("UIWindow", 4).set_min_max(Vector2.ZERO, Vector2.INF)
	
	settings_manager.register_setting("borderless", Data.Type.BOOL, set_window_borderless, get_window_borderless, [window_borderless_changed])\
	.display("UIWindow", 5)
	
	settings_manager.register_status("root", Data.Type.BOOL, is_window_root, [])\
	.display("UIWindow", 6)
	
	close_requested.connect(_on_close_request)


## Process
func _process(delta: float) -> void:
	if get_position() != _previous_pos:
		window_position_changed.emit(get_position())
		_previous_pos = get_position()
	
	if get_size() != _previous_size:
		window_size_changed.emit(get_size())
		_previous_size = get_size()


## Sets the window title
func set_window_title(p_title: String) -> void:
	title = p_title
	window_title_changed.emit(title)


## Sets the base UIPanel to display
func set_base_panel(p_panel: UIPanel) -> void:
	if _base_panel:
		remove_child(_base_panel)
		_base_panel.queue_free()
	
	_base_panel = p_panel
	add_child(_base_panel)
	
	if _window_popups:
		_window_popups.move_to_front()
	
	base_panel_changed.emit(_base_panel)


## Sets the window popups container
func set_window_popups(p_popups: Control) -> void:
	_window_popups = p_popups
	add_child(_window_popups)


## Sets the display mode
func set_display_mode(p_display_mode) -> void:
	_display_mode = p_display_mode
	
	match _display_mode:
		DisplayMode.WINDOWED:
			set_mode(Window.MODE_WINDOWED)
		DisplayMode.MAXIMIZED:
			set_mode(Window.MODE_MAXIMIZED)
		DisplayMode.FULLSCREEN:
			set_mode(Window.MODE_FULLSCREEN)
	
	display_mode_changed.emit(_display_mode)


## Sets the window size
func set_window_size(p_window_size: Vector2i) -> void:
	set_size(p_window_size)


## Sets the window position
func set_window_position(p_position: Vector2i) -> void:
	set_position(p_position)


## Sets the borderless state
func set_window_borderless(p_borderless: bool) -> void:
	set_flag(Window.FLAG_BORDERLESS, p_borderless)


## Gets the window title
func get_window_title() -> String:
	return title


## Sets the base panel
func get_base_panel() -> UIPanel:
	return _base_panel


## Gets the window popups
func get_window_popups() -> Control:
	return _window_popups


## Gets the current DisplayMode
func get_display_mode() -> DisplayMode:
	return _display_mode


## Gets the window position
func get_window_position() -> Vector2i:
	return get_position()


## Gets the window size
func get_window_size() -> Vector2i:
	return get_size()


## Gets the borderless state
func get_window_borderless() -> bool:
	return get_flag(Window.FLAG_BORDERLESS)


## Returns true if this node is the root window in the program
func is_window_root() -> bool:
	if get_parent():
		return false
	else:
		return true


## Called for a close request
func _on_close_request() -> void:
	Interface.close_window(self)

# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name ClientInterface extends Node
## Main script for the Spectrum Lighting Controller UI interface


## Emitted when a resolve request is required
signal resolve_requested(type: ResolveType, hint: ResolveHint, classname: String, color_hint: Color)


## Enum for ResolveTypes
enum ResolveType {
	NONE,			## Disables resolve mode
	ANY,			## Resolves anything
	COMPONENT,		## Resolves an EngineComponent
	UIPANEL			## Resolves a UIPanel
}


## Enum for ResolveHint
enum ResolveHint {
	NONE,			## Default state
	SELECT,			## Requests to select a component
	ASSIGN,			## Requests to assign into
	STORE,			## Requests to store into
	EDIT,			## Requests to edit
	RENAME,			## Requests to rename a component
	EXECUTE,		## Requests to execute a function
	STOP,			## Requests to stop a function
	DELETE			## Requests to delete a component
}


## Enum for all WindowPopups
enum WindowPopup {
	PANEL_PICKER,	## PanelPicker class for selecting UIPanels
	PANEL_SETTINGS	## PanelPicker class for selecting UIPanels
}


## Stores configuration for a WindowPopup instance
class PopupConfig:
	## Name of the node in the WindowPopups.tscn scene
	var node_name: String = ""
	
	## Name of the method used to apply the value
	var setter: String = ""
	
	## Maps each window to its associated node
	var nodes: Dictionary[Window, UIBase]
	
	## Maps each window to its setter callable
	var setter_callables: Dictionary[Window, Callable]
	
	## Maps each popups active state to the window
	var active_state: Dictionary[Window, bool]
	
	## Maps each window to its Promise
	var promises: Dictionary[Window, Promise]
	
	
	## Constructor
	func _init(p_node_name: String = "", p_setter: String = "") -> void:
		node_name = p_node_name
		setter = p_setter


## The current resolve hint, if any
var _current_resolve_hint: ResolveHint = ResolveHint.NONE

## The current resolve mode, if any
var _current_resolve_type: ResolveType = ResolveType.NONE

## The current resolve classname
var _current_resolve_classname: String = ""

## The current resolve color
var  _current_resolve_color: Color = Color.TRANSPARENT

## The resolve Promise
var _resolve_promise: Promise = Promise.new()

## Colors for each resolve hint
var _resolve_hint_colors: Dictionary[ResolveHint, Color] = {
	ResolveHint.NONE:		ThemeManager.Colors.ResolveHint.None,
	ResolveHint.SELECT:		ThemeManager.Colors.ResolveHint.Select,
	ResolveHint.ASSIGN:		ThemeManager.Colors.ResolveHint.Assign,
	ResolveHint.STORE:		ThemeManager.Colors.ResolveHint.Store,
	ResolveHint.EDIT:		ThemeManager.Colors.ResolveHint.Edit,
	ResolveHint.RENAME:		ThemeManager.Colors.ResolveHint.Rename,
	ResolveHint.EXECUTE:	ThemeManager.Colors.ResolveHint.Execute,
	ResolveHint.STOP:		ThemeManager.Colors.ResolveHint.Stop,
	ResolveHint.DELETE:		ThemeManager.Colors.ResolveHint.Delete,
}


## Stores configuration for each WindowPopup that will be instanced on each window
var _window_popup_config: Dictionary[WindowPopup, PopupConfig] = {
	WindowPopup.PANEL_PICKER: PopupConfig.new("PanelPicker", ""),
	WindowPopup.PANEL_SETTINGS: PopupConfig.new("UIPanelSettings", "set_panel")
}

## The WindowPopups scene to be instanced on each window
var _window_popups_scene: PackedScene = load("res://WindowPopups.tscn")

## All active fade animations
var _active_fade_animations: Dictionary[Object, Dictionary]


## Init ClientInterface
func _ready() -> void:
	var popups: Control = _window_popups_scene.instantiate()
	
	_register_window_popups(popups, get_tree().root)
	get_tree().root.add_child.call_deferred(popups)


## Registers all WindowPopups into the corrisponding PopupConfig class
func _register_window_popups(p_window_popups: Control, p_window: Window) -> void:
	for window_popup: WindowPopup in _window_popup_config.keys():
		var config: PopupConfig = _window_popup_config[window_popup]
		var popup: UIBase = p_window_popups.get_node(config.node_name)
		var setter: Callable
		var resolve_signal: Signal = popup.get_custom_signal_or_default() if popup is UIPopup else Signal()
		var reject_signal: Signal = popup.canceled if popup is UIPopup else popup.close_request
		var promise: Promise = Promise.new()
		
		if config.setter:
			setter = Callable(popup, config.setter)
		
		## TEMP workaround untill Godot 4.5's vararg functions are avaibal
		if not resolve_signal.is_null():
			resolve_signal.connect(func (arg1: Variant = null, arg2: Variant = null, arg3: Variant = null, arg4: Variant = null, arg5: Variant = null, arg6: Variant = null, arg7: Variant = null, arg8: Variant = null):
				var args: Array = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8]
				
				promise.resolve(args.filter(func (arg):
					return not (arg == null)
				))
				
				_hide_window_popup(window_popup, p_window)
			)
		
		## TEMP workaround untill Godot 4.5's vararg functions are avaibal
		if not reject_signal.is_null():
			reject_signal.connect(func (arg1: Variant = null, arg2: Variant = null, arg3: Variant = null, arg4: Variant = null, arg5: Variant = null, arg6: Variant = null, arg7: Variant = null, arg8: Variant = null):
				var args: Array = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8]
				
				promise.reject(args.filter(func (arg):
					return not (arg == null)
				))
				
				_hide_window_popup(window_popup, p_window)
			)
		
		config.nodes[p_window] = popup
		config.setter_callables[p_window] = setter
		config.active_state[p_window] = false
		config.promises[p_window] = promise
		popup.hide()


## Shows the given WindowPopup
func _show_window_popup(p_popup_type: WindowPopup, p_source: Node, p_setter_arg: Variant) -> Promise:
	var window = p_source.get_window()
	var config: PopupConfig = _window_popup_config[p_popup_type]
	var popup: UIPanel = config.nodes[window]
	var promise: Promise = config.promises[window]
	
	if config.active_state[window]:
		config.promises[window].clear()
	
	if p_setter_arg:
		config.setter_callables[window].call(p_setter_arg)
	
	config.active_state[window] = true
	show_and_fade(popup)
	popup.move_to_front()
	
	return promise


## Hides and active window popup
func _hide_window_popup(p_popup_type: WindowPopup, p_window: Window) -> void:
	var config: PopupConfig = _window_popup_config[p_popup_type]
	
	if not config.active_state[p_window]:
		return
	
	config.active_state[p_window] = false
	fade_and_hide(config.nodes[p_window])
	config.promises[p_window].clear()


## Prompts the user to select a UIPanel
func prompt_panel_picker(p_source: Node) -> Promise:
	return _show_window_popup(WindowPopup.PANEL_PICKER, p_source, null)


## Promps the user with UIPaneSettings
func prompt_panel_settings(p_source: Node, p_panel: UIPanel) -> Promise:
	return _show_window_popup(WindowPopup.PANEL_SETTINGS, p_source, p_panel)


## Hides all popup panels
func hide_all_popup_panels() -> void:
	for popup_type: WindowPopup in _window_popup_config:
		_hide_window_popup(popup_type, get_window())


## Fades a property of an object and handles animation cleanup
func fade_property(p_object: Object, p_property: String, p_to: Variant, p_callback: Callable = Callable(), p_time: float = ThemeManager.Constants.Times.InterfaceFadeTime) -> void:
	kill_fade(p_object, p_property)
	var tween: Tween = get_tree().create_tween()
	
	tween.tween_property(p_object, p_property, p_to, p_time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func ():
		_active_fade_animations[p_object].erase(p_property)
		if p_callback.is_valid():
			p_callback.call()
	)
	
	_active_fade_animations.get_or_add(p_object, {})[p_property] = tween


## Kills a running fade
func kill_fade(p_object: Object, p_property: String) -> void:
	if _active_fade_animations.get(p_object, {}).has(p_property):
		_active_fade_animations[p_object][p_property].kill()
		_active_fade_animations[p_object].erase(p_property)


## Checks if a property is currently fading
func is_fading(p_control: Control, p_property: String) -> bool:
	return _active_fade_animations.get(p_control, {}).has(p_property)


## Shows and fades in a control
func show_and_fade(p_control: Control, p_callback: Callable = Callable(), p_time: float = ThemeManager.Constants.Times.InterfaceFadeTime) -> void:
	if p_control.visible and not is_fading(p_control, "modulate"):
		return
	
	p_control.modulate = Color.TRANSPARENT
	fade_property(p_control, "modulate", Color.WHITE, p_callback, p_time)
	p_control.show()


## Fades and hides a control
func fade_and_hide(p_control: Control, p_callback: Callable = Callable(), p_time: float = ThemeManager.Constants.Times.InterfaceFadeTime) -> void:
	if not p_control.visible and not is_fading(p_control, "modulate"):
		return
	
	p_control.modulate = Color.WHITE
	fade_property(p_control, "modulate", Color.TRANSPARENT, func ():
		p_control.hide()
		p_control.modulate = Color.WHITE
		
		if p_callback.is_valid():
			p_callback.call()
	, p_time)


## Sets the visibility of a control node with a fade time
func set_visible_and_fade(p_control: Control, p_visible: bool, p_callback: Callable = Callable(), p_time: float = ThemeManager.Constants.Times.InterfaceFadeTime) -> void:
	if p_visible:
		show_and_fade(p_control, p_callback, p_time)
	else:
		fade_and_hide(p_control, p_callback, p_time)


## Stops any current fade and shows the given control node
func show(p_control: Control) -> void:
	kill_fade(p_control, "modulate")
	p_control.modulate = Color.WHITE
	p_control.show()


## Stops any current fade and shows the given control node
func hide(p_control: Control) -> void:
	kill_fade(p_control, "modulate")
	p_control.modulate = Color.WHITE
	p_control.hide()


## Gets the current ResolveHint
func get_current_resolve_hint() -> ResolveHint:
	return _current_resolve_hint


## Gets the current ResolveType
func get_current_resolve_type() -> ResolveType:
	return _current_resolve_type


## Gets the current resolve classname
func get_current_resolve_classname() -> String:
	return _current_resolve_classname


## Gets the current resolve color
func get_current_resolve_color() -> Color:
	return _current_resolve_color


## Gets the color for a resolve hint
func get_resolve_color(p_resolve_hint: ResolveHint) -> Color:
	return _resolve_hint_colors[p_resolve_hint]


## Enables the ResolveMode
func enter_resolve_mode(p_resolve_type: ResolveType, p_resolve_hint: ResolveHint, p_classname: String) -> Promise:
	_current_resolve_type = p_resolve_type
	_current_resolve_hint = p_resolve_hint
	_current_resolve_classname = p_classname
	_current_resolve_color = get_resolve_color(_current_resolve_hint)
	
	resolve_requested.emit(_current_resolve_type, _current_resolve_hint, _current_resolve_classname, _current_resolve_color)
	return _resolve_promise


## Exits resolve mode
func exit_resolve_mode() -> bool:
	if _current_resolve_type == ResolveType.NONE:
		return false
	
	_current_resolve_type = ResolveType.NONE
	_current_resolve_hint = ResolveHint.NONE
	_current_resolve_classname = "p_classname"
	_current_resolve_color = Color.TRANSPARENT
	
	resolve_requested.emit(_current_resolve_type, _current_resolve_hint, _current_resolve_classname, _current_resolve_color)
	return true

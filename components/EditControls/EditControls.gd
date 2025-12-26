# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

@tool

class_name UIPanelEditControls extends Control
## UI Panel's edit controls and close/resize features


## Whether to show the edit button
@export var show_back: bool = false: set = set_show_back

## Whether to show the edit button
@export var show_edit: bool = true: set = set_show_edit

## Whether to show the settings button
@export var show_settings: bool = true: set = set_show_settings

## Whether to show the close button
@export var show_close: bool = false: set = set_show_close

## Whether to show the move/resize handle
@export var show_handle: bool = true: set = set_show_handle


@export_group("Nodes")

## Reference to the edit button
@export var back_button: Button = null

## Reference to the edit button
@export var edit_button: Button = null

## Reference to the settings button
@export var settings_button: Button = null

## Reference to the close button
@export var close_button: Button = null

## Reference to the move/resize handle
@export var move_resize_handle: Control = null

## The Control to be used for resolves
@export var resolve_box: Control


## Ready
func _ready() -> void:
	set_show_edit(show_edit)
	set_show_back(show_back)
	set_show_settings(show_settings)
	set_show_close(show_close)
	set_show_handle(show_handle)
	
	Interface.resolve_requested.connect(_handle_resolve_request)
	_handle_resolve_request(Interface.get_current_resolve_type(), Interface.get_current_resolve_hint(), Interface.get_current_resolve_classname(), Interface.get_current_resolve_color())


## Sets the visibility of the edit button
func set_show_back(p_show_back: bool) -> void:
	show_back = p_show_back
	
	if back_button:
		back_button.visible = show_back
	
	_update_visability()


## Sets the visibility of the edit button
func set_show_edit(p_show_edit: bool) -> void:
	show_edit = p_show_edit
	
	if edit_button:
		edit_button.visible = show_edit
	
	_update_visability()


## Sets the visibility of the settings button
func set_show_settings(p_show_settings: bool) -> void:
	show_settings = p_show_settings
	
	if settings_button:
		settings_button.visible = show_settings
	
	_update_visability()


## Sets the visibility of the close button
func set_show_close(p_show_close: bool) -> void:
	show_close = p_show_close
	
	if close_button:
		close_button.visible = show_close
	
	_update_visability()


## Sets the visibility of the move/resize handle
func set_show_handle(p_show_handle: bool) -> void:
	show_handle = p_show_handle
	
	if move_resize_handle:
		move_resize_handle.visible = show_handle
	
	_update_visability()


## Updates the visability of this EditControl if all items are hidden
func _update_visability() -> void:
	if not show_back and not show_edit and not show_settings and not show_close and not show_handle:
		hide()
	else:
		show()


## Called when Interface.enter_resolve() is called
func _handle_resolve_request(p_type: Interface.ResolveType, p_hint: Interface.ResolveHint, p_classname: String, p_color_hint: Color):
	if p_type in [Interface.ResolveType.ANY, Interface.ResolveType.UIPANEL]:
		if not resolve_box.visible:
			resolve_box.show()
			resolve_box.modulate = Color.TRANSPARENT
		
		Interface.fade_property(resolve_box, "modulate", p_color_hint, Callable(), ThemeManager.Constants.Times.EditControlResolve)
	
	else:
		if resolve_box.is_visible():
			Interface.fade_property(resolve_box, "modulate", Color.TRANSPARENT, resolve_box.hide, ThemeManager.Constants.Times.EditControlResolve)

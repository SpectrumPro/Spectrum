# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

@tool

class_name UIPanelEditControls extends Control
## UI Panel's edit controls and close/resize features


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
@export var edit_button: Button = null

## Reference to the settings button
@export var settings_button: Button = null

## Reference to the close button
@export var close_button: Button = null

## Reference to the move/resize handle
@export var move_resize_handle: Control = null


## Ready
func _ready() -> void:
	set_show_edit(show_edit)
	set_show_settings(show_settings)
	set_show_close(show_close)
	set_show_handle(show_handle)


## Sets the visibility of the edit button
func set_show_edit(p_show_edit: bool) -> void:
	show_edit = p_show_edit
	
	if edit_button:
		edit_button.visible = show_edit


## Sets the visibility of the settings button
func set_show_settings(p_show_settings: bool) -> void:
	show_settings = p_show_settings
	
	if settings_button:
		settings_button.visible = show_settings


## Sets the visibility of the close button
func set_show_close(p_show_close: bool) -> void:
	show_close = p_show_close
	
	if close_button:
		close_button.visible = show_close


## Sets the visibility of the move/resize handle
func set_show_handle(p_show_handle: bool) -> void:
	show_handle = p_show_handle
	
	if move_resize_handle:
		move_resize_handle.visible = show_handle

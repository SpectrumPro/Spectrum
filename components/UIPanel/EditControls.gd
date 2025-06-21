# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UIPanelEditControls extends Control
## UI Panel's edit controls and close button


## The edit button
@export var edit_button: Button = null

## The settings button
@export var settings_button: Button = null

## The close button
@export var close_button: Button = null

## The move and resize handle
@export var move_resize_handle: TextureRect

## Sets the visibility of the edit button
@export var show_edit: bool = true

## Sets the visibility of the settings button
@export var show_settings: bool = true

## Sets the visibility of the close button
@export var show_close: bool = false

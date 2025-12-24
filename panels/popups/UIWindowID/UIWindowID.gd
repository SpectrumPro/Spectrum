# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UIWindowID extends UIPopup
## UIWindowID


## The Label to display the window name
@export var label: Label


## The current UIWindow
var _window: UIWindow


## init
func _init() -> void:
	super._init()
	
	_set_class_name("UIWindowID")


## Ready
func _ready() -> void:
	_window = Interface.get_window_node(self)
	_window.window_title_changed.connect(label.set_text)
	label.set_text(_window.get_window_title())

# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UICore extends UIPanel
## CoreUI panel for specturm UIV3


## The UICorePrimarySideBar side bar
@export var _side_bar: UICorePrimarySideBar

## The startup background container 
@export var _startup_bg: PanelContainer


## Init
func _init() -> void:
	super._init()
	
	_set_class_name("UICore")


## Ready
func _ready() -> void:
	settings_manager.require("side_bar_settings", _side_bar.settings_manager)
	
	_startup_bg.show()
	
	if get_parent() is UIWindow:
		set_menu_bar_visible(false)
	
	await get_tree().create_timer(0.5).timeout
	Interface.fade_property(_startup_bg, "modulate", Color.TRANSPARENT, _startup_bg.hide, 0.3)


## Saves all the tabs
func _save() -> Dictionary:
	return {
		"tabs": _side_bar.save(),
	}


## Loads all the tabs
func _load(saved_data: Dictionary) -> void:
	_side_bar.load(saved_data)

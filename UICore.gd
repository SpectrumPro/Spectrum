# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UICore extends UIPanel
## CoreUI panel for specturm UIV3


## The UICorePrimarySideBar side bar
@export var _side_bar: UICorePrimarySideBar


## Saves all the tabs
func _save() -> Dictionary:
	return {
		"tabs": _side_bar.save(),
	}


## Loads all the tabs
func _load(saved_data: Dictionary) -> void:
	_side_bar.load(saved_data)

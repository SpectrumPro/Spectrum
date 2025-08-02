# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name PanelMenuBar extends UIComponent
## PanelMenuBar Component


## Popup style state
var _popup_style: bool = false


## Sets the popup style state
func set_popup_style(p_popup_style: bool) -> bool:
	if p_popup_style == _popup_style:
		return false
	
	_popup_style = p_popup_style
	add_theme_stylebox_override("panel", ThemeManager.StyleBoxes.PanelMenuBarPopup if _popup_style else ThemeManager.StyleBoxes.PanelMenuBarBase)
	
	return true

# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.


class_name UISetting extends UIPanel
## Settings Panel


## Container for tab buttons
@export var _tab_button_container: HBoxContainer


## Enum for each tab
enum Tab {ClientSettings, ServerSettings, NetworkManager, Shortcuts}


## Switched to the given tab
func switch_to_tab(p_tab: Tab) -> void:
	_tab_button_container.get_child(p_tab).button_pressed = true

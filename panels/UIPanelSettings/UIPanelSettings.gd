# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UIPanelSettings extends UIPanel
## Settings for UI Panels


## Emitted when the panel is changed
signal panel_changed(panel)


## UIPanelSettingsShortcuts Settings Page
@export var _shortcuts_panel: UIPanelSettingsShortcuts

## The SettingsManagerView for settings
@export var _settings_panel: SettingsManagerView


## The current UIPanel
var _panel: UIPanel


## Init
func _init() -> void:
	super._init()
	_set_class_name("UIPanelSettings")


## Sets the panelvvc
func set_panel(panel: UIPanel) -> void:
	_panel = panel
	_settings_panel.set_manager(_panel.settings_manager)
	
	panel_changed.emit(_panel)


## Gets the UIPanelSettingsShortcuts Settings page
func get_shortcut_settings() -> UIPanelSettingsShortcuts:
	return _shortcuts_panel

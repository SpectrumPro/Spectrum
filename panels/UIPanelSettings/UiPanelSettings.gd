# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIPanelSettings extends UIPanel
## Settings for UI Panels


## Emitted when the panel is changed
signal panel_changed(panel)


## UIPanelSettingsShortcuts Settings Page
@export var _shortcuts_panel: UIPanelSettingsShortcuts

## The ClientComponentSettings for settings
@export var _settings_panel: ClientComponentSettings


## The current UIPanel
var _panel: UIPanel


## Sets the panelvvc
func set_panel(panel: UIPanel) -> void:
	_panel = panel
	_settings_panel.set_component(_panel)
	panel_changed.emit(_panel)


## Gets the UIPanelSettingsShortcuts Settings page
func get_shortcut_settings() -> UIPanelSettingsShortcuts:
	return _shortcuts_panel

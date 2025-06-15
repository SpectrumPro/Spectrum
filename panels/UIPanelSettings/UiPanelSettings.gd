# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIPanelSettings extends UIPanel
## Settings for UI Panels


## Emitted when the panel is changed
signal panel_changed(panel)


## The current UIPanel
var _panel: UIPanel


## Sets the panel
func set_panel(panel: UIPanel) -> void:
	_panel = panel
	panel_changed.emit(panel)

# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name DataInputSettingsManager extends DataInput
## DataInput for Data.Type.SETTINGSMANAGER


## The SettingsManagerView to show the SettingsManager
var _settings_manager_view: SettingsManagerView


## Ready
func _ready() -> void:
	_data_type = Data.Type.SETTINGSMANAGER
	_settings_manager_view = $SettingsManagerView
	_outline = $Outline
	_focus_node = self


## Called when the orignal value is changed
func _module_value_changed(p_value: Variant) -> void:
	if p_value is SettingsManager:
		_settings_manager_view.set_manager(p_value)


## Override for a reset function
func _reset() -> void:
	_settings_manager_view.reset()

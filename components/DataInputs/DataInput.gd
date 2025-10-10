# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name DataInput extends Control
## DataInput base class


## The main Label
var _label: Label

## The LineEdit outline
var _outline: Panel

## The currentl SettingsModle
var _module: SettingsModule

## Currently value unsaved state
var _unsaved: bool = false

## The DataType of this DataInput
var _data_type: Data.Type = Data.Type.NULL

## Editable state
var _editable: bool = true


## Resets this DataInput
func reset() -> void:
	if _module:
		_module.unsubscribe(_module_value_changed)
	
	if _outline:
		_outline.set_modulate(Color.TRANSPARENT)
	
	_unsaved = false
	_module = null
	
	_reset()


## Sets the SettingsMoudle to edit
func set_module(p_module: SettingsModule) -> bool:
	if not Data.do_types_match_base(p_module.get_data_type(), _data_type):
		return false
	
	reset()
	_module = p_module
	_module.subscribe(_module_value_changed)
	
	_settings_module_changed(_module)
	_module_value_changed(_module.get_getter().call())
	
	set_editable(_module.is_editable())
	return true


## Shows or hides the label
func set_show_label(p_show_label: bool) -> void:
	_label.set_visible(p_show_label)


## Sets the label text
func set_label_text(p_label_text: String) -> void:
	_label.set_text(p_label_text) 


## Sets the editable state
func set_editable(p_editable: bool) -> void:
	_editable = p_editable
	_set_editable(_editable)


## Gets the SettingsMoudle
func get_module() -> SettingsModule:
	return _module


## Gets the label is_visible state
func get_show_label() -> bool:
	return _label.is_visible()


## Gets the label tetx
func get_label_text() -> String:
	return _label.get_text()


## Gets the data type
func get_data_type() -> Data.Type:
	return _data_type


## Gets the editable state
func get_editable() -> bool:
	return _editable


## Updates the outline to match the return value of the setter
func _update_outline_feedback(p_state: Variant) -> void:
	_unsaved = false
	Interface.kill_fade(_outline, "modulate") 
	
	if (p_state is bool and p_state) or p_state is not bool:
		_outline.set_modulate(ThemeManager.Colors.Statuses.Normal)
	else:
		_outline.set_modulate(ThemeManager.Colors.Statuses.Error)
	
	await get_tree().create_timer(ThemeManager.Constants.Times.DataInputOutlineWait).timeout
	
	if not _unsaved:
		Interface.fade_property(_outline, "modulate", Color.TRANSPARENT, Callable(), ThemeManager.Constants.Times.DataInputOutlineFade)


## Marks this DataInput as unsaved
func _make_unsaved() -> void:
	if not _unsaved:
		_unsaved = true
		_outline.set_modulate(ThemeManager.Colors.Statuses.UnsavedData)


## Override this function to provide a SettingsModule to display
func _settings_module_changed(p_module: SettingsModule) -> void:
	pass


## Called when the orignal value is changed
func _module_value_changed(p_value: Variant) -> void:
	pass


## Called when the editable state is changed
func _set_editable(p_editable: bool) -> void:
	pass


## Override for a reset function
func _reset() -> void:
	pass

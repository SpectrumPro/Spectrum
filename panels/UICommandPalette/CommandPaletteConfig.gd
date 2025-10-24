# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name CommandPaletteEntry extends Object
## A configuration for items shown in the CommandPalette.


## Defines whether a command is tied to a global class or a specific instance.
enum ObjectType {
	GLOBAL,			## Command applies to all classes globally.
	INSTANCED,		## Command applies only to a specific instance of a class.
}

## Defines the origin of the "object deleted" signal.
enum DeleteSignalOrigin {
	NONE,			## There is not delete signal
	GLOBAL,			## Signal comes from the global object management script.
	PER_CLASS,		## Signal comes from the object itself that is being deleted.
}


## The type of object this entry belongs to (global or instanced).
var _object_type: ObjectType = ObjectType.GLOBAL

## The origin of the delete signal for this entry.
var _delete_signal_origin: DeleteSignalOrigin = DeleteSignalOrigin.GLOBAL

## Reference to the settings manager when _object_type is GLOBAL.
var _settings_manager: SettingsManager

## The class name for the class
var _class_name: String = ""

## The signal emitted when this object is created.
var _create_signal: Signal = Signal()

## The delete signal. If _delete_signal_origin is GLOBAL, this is a Signal object. else PER_CLASS, this is the string name of the signal
var _delete_signal: Variant = ""


## Init
func _init(p_object_type: ObjectType, p_delete_signal_origin: DeleteSignalOrigin, p_settings_manager: SettingsManager, p_class_name: String, p_create_signal: Signal = Signal(), p_delete_signal: Variant = "") -> void:
	_object_type = p_object_type
	_delete_signal_origin = p_delete_signal_origin
	_settings_manager = p_settings_manager
	_class_name = p_class_name
	_create_signal = p_create_signal
	_delete_signal = p_delete_signal


## Gets the object type
func get_object_type() -> ObjectType:
	return _object_type


## Gets the delete signal origin
func get_delete_signal_origin() -> DeleteSignalOrigin:
	return _delete_signal_origin


## Gets the settings manager
func get_settings_manager() -> SettingsManager:
	return _settings_manager


## Gets the class name
func get_class_name() -> String:
	return _class_name


## Gets the create signal
func get_create_signal() -> Signal:
	return _create_signal


## Gets the delete signal
func get_delete_signal() -> Variant:
	return _delete_signal



## Sets the object type
func set_object_type(p_object_type: ObjectType) -> CommandPaletteEntry:
	_object_type = p_object_type
	return self


## Sets the delete signal origin
func set_delete_signal_origin(p_delete_signal_origin: DeleteSignalOrigin) -> CommandPaletteEntry:
	_delete_signal_origin = p_delete_signal_origin
	return self


## Sets the settings manager
func set_settings_manager(p_settings_manager: SettingsManager) -> CommandPaletteEntry:
	_settings_manager = p_settings_manager
	return self


## Sets the class name
func set_class_name(p_class_name: String) -> CommandPaletteEntry:
	_class_name = p_class_name
	return self


## Sets the create signal
func set_create_signal(p_create_signal: Signal) -> CommandPaletteEntry:
	_create_signal = p_create_signal
	return self


## Sets the delete signal
func set_delete_signal(p_delete_signal: Variant) -> CommandPaletteEntry:
	_delete_signal = p_delete_signal
	return self

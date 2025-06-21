# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name DMXFixture extends Fixture
## Dmx Fixture


## Emitted when the channel is changed
signal channel_changed(channel: int)

## Emitted when the manifest is changed
signal manifest_changed(manifest: FixtureManifest)


## The DMX channel of this fixture
var _channel: int = 0

## The mode of this fixture
var _mode: String = ""

## Stores all active values per parameter
## { "zone": { "parameter": { value: float, function: String } } }
var _active_values: Dictionary[String, Dictionary]

## All the input value overrides as raw values
## { "zone": { "parameter": { "value": float, "function": String } } }
var _raw_override_layers: Dictionary[String, Dictionary] = {}

## The FixtureManifest for this fixture
var _manifest: FixtureManifest = null


func _component_ready() -> void:
	_set_self_class("DMXFixture")
	
	register_callback("on_channel_changed", _set_channel)
	register_setting("DMXFixture", "channel", set_channel, get_channel, channel_changed, Utils.TYPE_INT, 0, "Channel", 1, 512)


## Gets the channel
func get_channel() -> int:
	return _channel


## Sets the channel
func set_channel(p_channel: int) -> Promise:
	return rpc("set_channel", [p_channel])


## Gets the FixtureManifest
func get_manifest() -> FixtureManifest:
	return _manifest


## Gets all the override values
func get_all_override_values() -> Dictionary:
	return _raw_override_layers.duplicate(true)


## Gets all the values
func get_all_values() -> Dictionary:
	return _active_values.duplicate(true)


## Gets all the parameters and there category from a zone
func get_parameter_categories(p_zone: String) -> Dictionary:
	return _manifest.get_categorys(_mode, p_zone)


## Gets all the parameter functions
func get_parameter_functions(p_zone: String, p_parameter: String) -> Array:
	return _manifest.get_parameter_functions(_mode, p_zone, p_parameter)


## Gets the default value of a parameter
func get_default(p_zone: String, p_parameter: String, p_function: String = "", p_raw_dmx: bool = false) -> float:
	if p_function == "":
		p_function = get_default_function(p_zone, p_parameter)
	
	var dmx_value: int = _manifest.get_mode(_mode).zones[p_zone][p_parameter].functions[p_function].default
	var range: Array = _manifest.get_mode(_mode).zones[p_zone][p_parameter].functions[p_function].dmx_range

	if p_raw_dmx:
		return dmx_value
	else:
		return remap(dmx_value, range[0], range[1], 0.0, 1.0)


## Gets the default function for a zone and parameter, or the first function if none can be found
func get_default_function(p_zone: String, p_parameter: String) -> String:
	var default_function: String = _manifest.get_mode(_mode).zones[p_zone][p_parameter].default_function
	var functions: Dictionary = _manifest.get_mode(_mode).zones[p_zone][p_parameter].functions

	if functions.has(default_function):
		return default_function
	else:
		return functions.keys()[0]


## Gets the current value, or the default
func get_current_value(p_zone: String, p_parameter: String, p_allow_default: bool = true) -> float:
	return _active_values.get(p_zone, {}).get(p_parameter, {}).get("value", get_default(p_zone, p_parameter) if p_allow_default else 0.0)


## Gets all the zones
func get_zones() -> Array[String]:
	return _manifest.get_zones(_mode)


## Checks if this DMXFixture has any overrides
func has_overrides() -> bool:
	return _raw_override_layers != {}


## Checks if this fixture has a parameter
func has_parameter(p_zone: String, p_parameter: String, p_function: String = "") -> bool:
	if not _manifest:
		return false
	
	if p_function:
		return _manifest.has_function(_mode, p_zone, p_parameter, p_function)
	else:
		return _manifest.has_parameter(_mode, p_zone, p_parameter)


## Checks if a parameter is a force default
func has_force_default(p_parameter: String) -> bool:
	return _manifest.has_force_default(p_parameter)


## Checks if this DMXFixture has a function that can fade
func function_can_fade(p_zone: String, p_parameter: String, p_function: String) -> bool:
	return _manifest.function_can_fade(_mode, p_zone, p_parameter, p_function)


## Internl: Sets the channel
func _set_channel(p_channel: int) -> void:
	_channel = p_channel
	channel_changed.emit(_channel)


## Sets the FixtureManifest
func _set_manifest(p_manifest: FixtureManifest, p_mode: String) -> void:
	_mode = p_mode
	_manifest = p_manifest
	
	manifest_changed.emit(_manifest)


## Internal: Sets a parameter to a float value
func _set_parameter(p_zone: String, p_parameter: String, p_function: String, p_value: Variant) -> void:
	_active_values.get_or_add(p_zone, {})[p_parameter] = {"value": p_value, "function": p_function}
	parameter_changed.emit(p_zone, p_parameter, p_function, p_value)


## Internal: Erases the parameter on the given layer
func _erase_parameter(p_zone: String, p_parameter: String) -> void:
	_active_values.get_or_add(p_zone, {}).erase(p_parameter)
	parameter_erased.emit(p_parameter, p_zone)


## Internal: Sets a parameter override to a float value
func _set_override(p_zone: String, p_parameter: String, p_function: String, p_value: float) -> void:
	_raw_override_layers.get_or_add(p_zone, {})[p_parameter] = {"value": p_value, "function": p_function}
	override_changed.emit(p_zone, p_parameter, p_function, p_value)


## Internal: Erases the parameter override 
func _erase_override(p_zone: String, p_parameter: String) -> void:
	if _raw_override_layers.get_or_add(p_zone, {}).erase(p_parameter) and not _raw_override_layers[p_zone]:
		_raw_override_layers.erase(p_zone)
		
	override_erased.emit(p_zone, p_parameter)


## Internal: Erases all overrides
func _erase_all_overrides() -> void:
	_raw_override_layers.clear()
	all_override_removed.emit()


## Saves this DMXFixture to a dictonary
func _serialize_request() -> Dictionary:
	return {
		 "channel": _channel
	}


## Loads this DMXFixture from a dictonary
func _load_request(p_serialized_data: Dictionary) -> void:
	_set_channel(type_convert(p_serialized_data.get("channel"), TYPE_INT))
	
	_mode = type_convert(p_serialized_data.get("mode", ""), TYPE_STRING)
	var manifest_uuid: String = type_convert(p_serialized_data.get("manifest_uuid"), TYPE_STRING)
	if manifest_uuid:
		FixtureLibrary.request_manifest(manifest_uuid).then(func (manifest: FixtureManifest):
			_set_manifest(manifest, _mode)
		)
	
	_raw_override_layers = Dictionary(type_convert(p_serialized_data.get("raw_override_layers", {}), TYPE_DICTIONARY), TYPE_STRING, "", null, TYPE_DICTIONARY, "", null)
	_active_values = Dictionary(type_convert(p_serialized_data.get("active_values", {}), TYPE_DICTIONARY), TYPE_STRING, "", null, TYPE_DICTIONARY, "", null)

# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name Fixture extends EngineComponent
## Engine class to control parameters of fixtures


## Emitted when one of the channels of this fixture is changed 
signal color_changed(color: Color)
signal white_intensity_changed(value: int)
signal amber_intensity_changed(value: int)
signal uv_intensity_changed(value: int)
signal dimmer_changed(value: int)

## Emitted when the mode of the fixture is change
#signal mode_changed(mode: int)

## Emitted when the channel of the fixture is changed
signal channel_changed(new_channel: int)

## Emitted when an override value is changed
signal override_value_changed(value: Variant, channel_key: String)

## Emitted when an override value is removed
signal override_value_removed(channel_key: String)


## Stores all the current values of the fixture
var _current_values: Dictionary = {}

## Stores all the supported channels for this fixture
var _channels: Array = []

## Stores all the fixtures override values, stored as {channel_key: value}
var _override_values: Dictionary = {
	
}

## Universe channel of this fixture
var _channel: int


## The highest dmx value allowed
const MAX_DMX_VALUE: int = 255


## Called when this EngineComponent is ready
func _component_ready() -> void:
	_set_self_class("Fixture")
	
	register_callback("on_color_changed", _set_color)
	register_callback("on_white_intensity_changed", _ColorIntensityWhite)
	register_callback("on_amber_intensity_changed", _ColorIntensityAmber)
	register_callback("on_uv_intensity_changed", _ColorIntensityUV)
	register_callback("on_dimmer_changed", _Dimmer)
	
	register_callback("on_channel_changed", _set_channel)
	register_callback("on_override_value_changed", _set_override_value)
	register_callback("on_override_value_removed", _remove_override_value)


## Sets the channel of this fixture
func set_channel(p_channel: int) -> void: rpc("set_channel", [p_channel])

## Gets the channel
func get_channel() -> int: return _channel


## Returns the current override value from the given channel_key, or null if not found
func get_override_value_from_channel_key(channel_key: String) -> Variant:
	return _override_values.get(channel_key)


## Returns the current override value from the given channel_key, or null if not found
func get_all_override_values() -> Variant:
	return _override_values.duplicate()


## Returns all current values 
func get_current_values() -> Variant:
	return _current_values.duplicate()


## Gets all the current supported channels
func get_channels() -> Array:
	return _channels.duplicate()


## INTERNAL: called when the color of this fixture is changed on the server
func _set_color(p_color: Color) -> void:
	_current_values.set_color = p_color
	color_changed.emit(_current_values.set_color)


## INTERNAL: called when the white intensity of this fixture is changed on the server
func _ColorIntensityWhite(p_value: int) -> void:
	_current_values.ColorIntensityWhite = p_value
	white_intensity_changed.emit(p_value)


## INTERNAL: called when the amber intensity of this fixture is changed on the server
func _ColorIntensityAmber(p_value: int) -> void:
	_current_values.ColorIntensityAmber = p_value
	amber_intensity_changed.emit(p_value)


## INTERNAL: called when the uv intensity of this fixture is changed on the server
func _ColorIntensityUV(p_value: int) -> void:
	_current_values.ColorIntensityUV = p_value
	uv_intensity_changed.emit(p_value)


## INTERNAL: called when the dimmer value of this fixture is changed on the server
func _Dimmer(p_value: int) -> void:
	_current_values.Dimmer = p_value
	dimmer_changed.emit(p_value)


## INTERNAL: called when the channel is changed on the server
func _set_channel(p_channel: int) -> void:
	_channel = p_channel
	channel_changed.emit(_channel)


## INTERNAL: called when an override value is changed on the server
func _set_override_value(p_value: Variant, p_channel_key: String) -> void:
	_override_values[p_channel_key] = p_value
	override_value_changed.emit(p_value, p_channel_key)


## INTERNAL: called when an override value is removed on the server
func _remove_override_value(p_channel_key: String) -> void:
	_override_values.erase(p_channel_key)
	override_value_removed.emit(p_channel_key)


## Called when this fixture is to be loaded from the server
func _load_request(serialized_data: Dictionary) -> void:
	_channel = serialized_data.get("channel", 1)
	
	_current_values.merge(serialized_data.get("current_values", {}), true)
	_override_values.merge(serialized_data.get("current_override_values", {}), true)
	
	_channels = serialized_data.get("channels", [])

# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

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
var current_values: Dictionary = {}


## Stores all the supported channels for this fixture
var channels: Array = []


## Stores all the fixtures override values, stored as {channel_key: value}
var _override_values: Dictionary = {
	
}

## Universe channel of this fixture
var channel: int


## The highest dmx value allowed
const MAX_DMX_VALUE: int = 255


## Called when this EngineComponent is ready
func _component_ready() -> void:
	name = "Fixture"
	self_class_name = "Fixture"


## Sets the channel of this fixture
func set_channel(p_channel: int) -> void:
	Client.send({
		"for": self.uuid,
		"call": "set_channel",
		"args": [p_channel]
	})


## Returns the current override value from the given channel_key, or null if not found
func get_override_value_from_channel_key(channel_key: String) -> Variant:
	return _override_values.get(channel_key)

#region Server Callbacks

## INTERNAL: called when the color of this fixture is changed on the server
func on_color_changed(new_color: Color) -> void:
	current_values.set_color = new_color
	color_changed.emit(current_values.set_color)


## INTERNAL: called when the white intensity of this fixture is changed on the server
func on_white_intensity_changed(value: int) -> void:
	current_values.ColorIntensityWhite = value
	white_intensity_changed.emit(value)


## INTERNAL: called when the amber intensity of this fixture is changed on the server
func on_amber_intensity_changed(value: int) -> void:
	current_values.ColorIntensityAmber = value
	amber_intensity_changed.emit(value)


## INTERNAL: called when the uv intensity of this fixture is changed on the server
func on_uv_intensity_changed(value: int) -> void:
	current_values.ColorIntensityUV = value
	uv_intensity_changed.emit(value)


## INTERNAL: called when the dimmer value of this fixture is changed on the server
func on_dimmer_changed(value: int) -> void:
	current_values.Dimmer = value
	dimmer_changed.emit(value)


## INTERNAL: called when the channel is changed on the server
func on_channel_changed(p_channel: int) -> void:
	channel = p_channel
	channel_changed.emit(channel_changed)


## INTERNAL: called when an override value is changed on the server
func on_override_value_changed(value: Variant, channel_key: String) -> void:
	_override_values[channel_key] = value
	override_value_changed.emit(value, channel_key)


## INTERNAL: called when an override value is removed on the server
func on_override_value_removed(channel_key: String) -> void:
	_override_values.erase(channel_key)
	override_value_removed.emit(channel_key)

#endregion



func _on_load_request(serialized_data: Dictionary) -> void:
	channel = serialized_data.get("channel", 1)
	
	current_values.merge(serialized_data.get("current_values", {}), true)
	channels = serialized_data.get("channels", [])
	

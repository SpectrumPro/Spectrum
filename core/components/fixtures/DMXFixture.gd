# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name DMXFixture extends Fixture
## Dmx Fixture


## Emitted when the channel is changed
signal channel_changed(channel: int)


## The DMX channel of this fixture
var _channel: int = 0


func _component_ready() -> void:
	_set_self_class("DMXFixture")
	
	register_callback("on_channel_changed", _set_channel)


## Gets the channel
func get_channel() -> int:
	return _channel


## Sets the channel
func set_channel(p_channel: int) -> Promise:
	return rpc("set_channel", [p_channel])


## Internl: Sets the channel
func _set_channel(p_channel: int) -> void:
	_channel = p_channel
	channel_changed.emit(_channel)


## Saves this DMXFixture to a dictonary
func _on_serialize_request() -> Dictionary:
	return {
		 "channel": _channel
	}


## Loads this DMXFixture from a dictonary
func _on_load_request(p_serialized_data: Dictionary) -> void:
	_set_channel(p_serialized_data.get("channel"))

# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Scene extends EngineComponent
## Engine class for creating and recalling saved data

signal state_changed(is_enabled: bool) ## Emmitted when this scene is enabled or dissabled

var fade_in_speed: int = 2 ## Fade in speed in seconds
var fade_out_speed: int = 2 ## Fade out speed in seconds

var engine: CoreEngine ## The CoreEngine this scene is a part of

var enabled: bool = false: set = set_enabled ## The current state of this scene
var save_data: Dictionary = {} ## Saved data for this scene


func set_enabled(is_enabled: bool) -> void:
	## Enabled or dissables this scene
	
	enabled = is_enabled
	
	if is_enabled:
		for fixture: Fixture in save_data:
			Core.animate(func(color): fixture.set_color(color, uuid), Color.BLACK, save_data[fixture].color, fade_in_speed)
	else:
		for fixture: Fixture in save_data:
			Core.animate(func(color): fixture.set_color(color, uuid), fixture.current_input_data[uuid].color, Color.BLACK, fade_out_speed)


func serialize() -> Dictionary:
	## Serializes this scene and returnes it in a dictionary
	
	return {
		"name": self.name,
		"fade_in_speed": fade_in_speed,
		"fade_out_speed": fade_out_speed,
		"save_data": serialize_save_data()
	}


func serialize_save_data() -> Dictionary:
	## Serializes save_data and returnes as a dictionary
	
	var serialized_save_data: Dictionary = {}
	
	for fixture: Fixture in save_data:
		serialized_save_data[fixture.uuid] = {}
		for save_key in save_data[fixture]:
			serialized_save_data[fixture.uuid][save_key] = Utils.serialize_variant(save_data[fixture][save_key])
	
	return serialized_save_data

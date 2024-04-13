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


func set_save_data(saved_data: Dictionary) -> void:
	save_data = saved_data
	
	for fixture: Fixture in save_data.keys():
		fixture.delete_request.connect(func(deleted_fixture: Fixture): save_data.erase(deleted_fixture))


func serialize() -> Dictionary:
	## Serializes this scene and returnes it in a dictionary
	
	return {
		"name": self.name,
		"fade_in_speed": fade_in_speed,
		"fade_out_speed": fade_out_speed,
		"save_data": serialize_save_data()
	}


func load_from(serialized_data: Dictionary) -> void:
	
	self.name = serialized_data.get("name", "")
	
	fade_in_speed = serialized_data.get("fade_in_speed", fade_in_speed)
	fade_out_speed = serialized_data.get("fade_out_speed", fade_out_speed)
	
	set_save_data(deserialize_save_data(serialized_data.get("save_data", {})))


func serialize_save_data() -> Dictionary:
	## Serializes save_data and returnes as a dictionary
	
	var serialized_save_data: Dictionary = {}
	
	for fixture: Fixture in save_data:
		serialized_save_data[fixture.uuid] = {}
		for save_key in save_data[fixture]:
			serialized_save_data[fixture.uuid][save_key] = Utils.serialize_variant(save_data[fixture][save_key])
	
	return serialized_save_data


func deserialize_save_data(serialized_data: Dictionary) -> Dictionary:
	## Deserializes save_data and returnes as a dictionary
	
	var deserialized_save_data: Dictionary = {}
	
	for fixture_uuid: String in serialized_data:
		var fixture_save: Dictionary = serialized_data[fixture_uuid]
		
		var deserialized_fixture_save = {}
		
		for saved_property: String in fixture_save:
			deserialized_fixture_save[saved_property] = Utils.deserialize_variant(fixture_save[saved_property])
		
		deserialized_save_data[engine.fixtures[fixture_uuid]] = deserialized_fixture_save
		
	return deserialized_save_data

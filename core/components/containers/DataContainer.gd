# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name DataContainer extends EngineComponent
## DataContainer stores fixture data


# Emitted when data is stored in this function
signal data_stored(fixture: Fixture, parameter_key: String, value: Variant)

## Emitted when data is erased from this function
signal data_erased(fixture: Fixture, parameter_key: String)

## Emitted when global data is stored in this function
signal global_data_stored(parameter_key: String, value: Variant)

## Emitted when globaldata is erased from this function
signal global_data_erased(parameter_key: String)


## Stored fixture data
var _fixture_data: Dictionary = {}

## Stored global data
var _global_data: Dictionary = {}


## Constructor
func _init(p_uuid: String = UUID_Util.v4(), p_name: String = name) -> void:
	_set_self_class("DataContainer")
	
	register_callback("on_data_stored", _store_data)
	register_callback("on_data_erased", _erase_data)
	register_callback("on_global_data_stored", _store_global_data)
	register_callback("on_global_data_erased", _erase_global_data)
	
	super._init(p_uuid, p_name)


## Gets all the fixture data
func get_fixture_data() -> Dictionary:
	return _fixture_data


## Gets all the global data
func get_global_data() -> Dictionary:
	return _global_data


## Stores data into this function
func store_data(p_fixture: Fixture, p_parameter_key: String, p_value: Variant) -> void: rpc("store_data", [p_fixture, p_parameter_key, p_value]) 

## Internal: Stores data into this function
func _store_data(p_fixture: Fixture, p_parameter_key: String, p_value: Variant) -> bool: 
	if not p_fixture in _fixture_data.keys():
		_fixture_data[p_fixture] = {}
	
	_fixture_data[p_fixture][p_parameter_key] = {
			"value": p_value,
		}
	
	data_stored.emit(p_fixture, p_parameter_key, p_value)
	
	return true


## Erases data from this function
func erase_data(p_fixture: Fixture, p_parameter_key: String) -> void: rpc("erase_data", [p_fixture, p_parameter_key])

## Internal: Erases data from this function
func _erase_data(p_fixture: Fixture, p_parameter_key: String) -> bool:
	var state: bool = _fixture_data[p_fixture].erase(p_parameter_key)
	
	if not _fixture_data[p_fixture]:
		_fixture_data.erase(p_fixture)
	
	if state:
		data_erased.emit(p_fixture, p_parameter_key)
	
	return state



## Stores global data into this function
func store_global_data(p_parameter_key: String, p_value: Variant) -> void: rpc("store_global_data", [p_parameter_key, p_value])

## Internal: Stores global data into this function
func _store_global_data(p_parameter_key: String, p_value: Variant) -> bool:
	if _global_data.get(p_parameter_key) == p_value:
		return false
	
	_global_data[p_parameter_key] = p_value
	global_data_stored.emit(p_parameter_key, p_value)
	
	return true


## Erases global data from this function
func erase_global_data(p_parameter_key: String) -> void: rpc("erase_global_data", [p_parameter_key])

## Internal: Erases global data from this function
func _erase_global_data(p_parameter_key: String) -> bool:
	var state: bool =  _global_data.erase(p_parameter_key)
	
	if state:
		global_data_erased.emit(p_parameter_key)
	
	return state


## Serializes the stored data
func _serialize_stored_data() -> Dictionary:
	var serialized_stored_data: Dictionary = {}
	
	for fixture: Fixture in _fixture_data:
		for parameter_key: String in _fixture_data[fixture].keys():
		
			var stored_item: Dictionary = _fixture_data[fixture][parameter_key]
			
			if not fixture.uuid in serialized_stored_data:
				serialized_stored_data[fixture.uuid] = {}
			
			serialized_stored_data[fixture.uuid][parameter_key] = {
				"value": var_to_str(stored_item.value),
			}
	
	return serialized_stored_data


## Loads the stored data, by calling the given method
func _load_stored_data(p_serialized_stored_data: Dictionary) -> void:
	for fixture_uuid: String in p_serialized_stored_data.keys():
		if ComponentDB.components.get(fixture_uuid) is Fixture:
			var fixture: Fixture = ComponentDB.components[fixture_uuid]
			
			for parameter_key: String in p_serialized_stored_data[fixture_uuid]:
				var stored_item: Dictionary = p_serialized_stored_data[fixture_uuid][parameter_key]
					
				_store_data(fixture, parameter_key, stored_item.get("value", 0))


## Serializes stored global data
func _serialize_stored_global_data() -> Dictionary:
	var serialized_stored_global_data: Dictionary = {}

	for parameter_key: String in _global_data.keys():
		var value: Variant = _global_data[parameter_key]

		serialized_stored_global_data[parameter_key] = {
			"value": var_to_str(value),
		}
	
	return serialized_stored_global_data


## Loads stored global data, by calling the given method
func _load_stored_global_data(p_serialized_stored_global_data: Dictionary) -> void:
	for parameter_key: String in p_serialized_stored_global_data.keys():
		var data: Dictionary = p_serialized_stored_global_data[parameter_key]
		
		_store_global_data(parameter_key, str_to_var(data.get("value", "0")))


## Serializes this DataContainer and returnes it in a dictionary
func _serialize() -> Dictionary:
	return {
		"fixture_data": _serialize_stored_data(),
		"global_data": _serialize_stored_global_data(),
	}


## Called when this DataContainer is to be loaded from serialized data
func _load(serialized_data: Dictionary) -> void:
	_load_stored_data(serialized_data.get("fixture_data", {}))
	_load_stored_global_data(serialized_data.get("global_data", {}))

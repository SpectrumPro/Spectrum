# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name Function extends EngineComponent
## Base class for all functions, scenes, cuelists ect


## Emitted when data is stored in this function
signal data_stored(fixture: Fixture, channel_key: String, value: Variant)

## Emitted when data is eraced from this function
signal data_eraced(fixture: Fixture, channel_key: String)

## Emitted when the current intensity of this function changes, eg the fade position of a scene
signal intensity_changed(percentage: float)


## List of functions that are allowed to be called by external control scripts.
var accessible_methods: Dictionary = {
	"intensity":{
		"set": set_intensity,
		"get": get_intensity,
		"signal": intensity_changed
	}
}


var _intensity: float = 0


func add_accessible_method(name: String, set_method: Callable, get_method: Callable = Callable(), changed_signal: Signal = Signal()) -> void:
	accessible_methods.merge({
		name: {
			"set": set_method,
			"get": get_method,
			"signal": changed_signal
		}
	})


func store_data(fixture: Fixture, channel_key: String, value: Variant) -> bool:
	return false


func erace_data(fixture: Fixture, channel_key: String) -> bool:
	return false


## Sets the intensity of this function, from 0.0 to 1.0
func set_intensity(p_intensity: float) -> void:
	Client.send_command(self.uuid, "set_intensity", [p_intensity])


## Returnes the intensity
func get_intensity() -> float:
	return _intensity


func on_intensity_changed(p_intensity: float) -> void:
	_intensity = p_intensity
	intensity_changed.emit(p_intensity)


## Static function to store saved fixture data into
func _store_data_static(fixture: Fixture, channel_key: String, value: Variant, stored_data: Dictionary) -> void:
	if not fixture in stored_data.keys():
		stored_data[fixture] = {}
	
	stored_data[fixture][channel_key] = {
			"value": value,
		}
	
	data_stored.emit(fixture, channel_key, value)


func _erace_data_static(fixture: Fixture, channel_key: String, stored_data: Dictionary) -> bool:
	if fixture in stored_data.keys():
		var return_state: bool = stored_data[fixture].erase(channel_key)
		
		if not stored_data[fixture]:
			stored_data.erase(fixture)
		
		if return_state:
			data_eraced.emit(fixture, channel_key)

		return return_state
	else:
		return false


## Loads the stored data, by calling the given method
func _load_stored_data(serialized_stored_data: Dictionary, stored_data: Dictionary, store_method: Callable = _store_data_static) -> void:
	for fixture_uuid: String in serialized_stored_data.keys():
		if fixture_uuid in Core.fixtures:
			var fixture: Fixture = Core.fixtures[fixture_uuid]

			for channel_key: String in serialized_stored_data[fixture_uuid]:
				var stored_item: Dictionary = serialized_stored_data[fixture_uuid][channel_key]

				store_method.call(fixture, channel_key, stored_item.get("value", 0), stored_data)

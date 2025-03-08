# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name Fixture extends EngineComponent
## Engine class to control parameters of fixtures


## Emitted when parameters are changed
signal parameter_changed(parameter: String, value: Variant, zone: String)

## Emitted when a parameter is erased
signal parameter_erased(parameter: String, zone: String)

## Emited when a parameter override is changed or added
signal override_changed(parameter: String, value: Variant, zone: String)

## Emitted when a parameter override is removed
signal override_erased(parameter: String, zone: String)

## Emitted when all overrides are removed
signal all_override_removed()


## Called when this EngineComponent is ready
func _init(p_uuid: String = UUID_Util.v4(), p_name: String = name) -> void:
	_set_self_class("Fixture")
	
	register_callback("on_parameter_changed", _set_parameter)
	register_callback("on_parameter_erased", _erase_parameter)
	register_callback("on_override_changed", _set_override)
	register_callback("on_override_erased", _erase_override)
	register_callback("on_all_override_removed", _erase_all_overrides)
	
	super._init(p_uuid, p_name)


## Sets a parameter to a float value
func set_parameter(parameter: String, value: float, layer_id: String, zone: String = "root") -> Promise:
	return rpc("set_parameter", [parameter, value, layer_id, zone])


## Internal: Sets a parameter to a float value
func _set_parameter(parameter: String, value: float, layer_id: String, zone: String = "root") -> void:
	return 


## Erases the parameter on the given layer
func erase_parameter(parameter: String, layer_id: String, zone: String = "root") -> Promise:
	return rpc("erase_parameter", [parameter, layer_id, zone])


## Internal: Erases the parameter on the given layer
func _erase_parameter(parameter: String, layer_id: String, zone: String = "root") -> void:
	return 


## Sets a parameter override to a float value
func set_override(parameter: String, value: float, zone: String = "root") -> Promise:
	return rpc("set_override", [parameter, value, zone])


## Internal: Sets a parameter override to a float value
func _set_override(parameter: String, value: float, zone: String = "root") -> void:
	return


## Erases the parameter override 
func erase_override(parameter: String, zone: String = "root") -> Promise:
	return rpc("erase_override", [parameter, zone])


## Internal: Erases the parameter override 
func _erase_override(parameter: String, zone: String = "root") -> void:
	return


## Erases all overrides
func erase_all_overrides() -> Promise:
	return rpc("erase_all_overrides")


## Internal: Erases all overrides
func _erase_all_overrides() -> void:
	return 


## Gets all the override values
func get_all_override_values() -> Dictionary:
	return {}


## Checks if this Fixture has any overrides
func has_overrides() -> bool:
	return false


## Gets all the parameters and there category from a zone
func get_parameter_categories(p_zone: String) -> Dictionary:
	return {}


## Gets all the parameter functions
func get_parameter_functions(p_zone: String, p_parameter: String) -> Array:
	return []

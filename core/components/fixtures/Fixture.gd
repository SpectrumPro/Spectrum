# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name Fixture extends EngineComponent
## Engine class to control parameters of fixtures


## Called when this EngineComponent is ready
func _init(p_uuid: String = UUID_Util.v4(), p_name: String = name) -> void:
	_set_self_class("Fixture")
	
	super._init(p_uuid, p_name)


## Sets a parameter to a float value
func set_parameter(parameter: String, value: float, layer_id: String, zone: String = "root") -> void:
	pass


## Erases the parameter on the given layer
func erase_parameter(parameter: String, layer_id: String, zone: String = "root") -> void:
	pass


## Sets a parameter override to a float value
func set_override(parameter: String, value: float, zone: String = "root") -> void:
	pass


## Erases the parameter override 
func erase_override(parameter: String, zone: String = "root") -> void:
	pass


## Erases all overrides
func erase_all_overrides() -> void:
	pass

# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name Function extends EngineComponent
## Base class for all functions, scenes, cuelists ect


## Emitted when the current intensity of this function changes, eg the fade position of a scene
signal intensity_changed(percentage: float)


## The intensity of this function
var _intensity: float = 0

## The DataContainer used to store scene data
var _data_container: DataContainer = DataContainer.new()


func _init(p_uuid: String = UUID_Util.v4(), p_name: String = name) -> void:
	_set_self_class("Function")
	add_accessible_method("intensity", [TYPE_FLOAT], set_intensity, get_intensity, intensity_changed, ["Intensity"])
	register_callback("on_intensity_changed", _set_intensity)
	
	Client.add_networked_object(_data_container.uuid, _data_container)
	
	super._init(p_uuid, p_name)


## Sets the intensity of this function, from 0.0 to 1.0
func set_intensity(p_intensity: float) -> Promise: 
	return rpc("set_intensity", [p_intensity])


## Internal: Sets the intensity
func _set_intensity(p_intensity: float) -> void:
	_intensity = p_intensity
	intensity_changed.emit(p_intensity)


## Returnes the intensity
func get_intensity() -> float: return _intensity

## Returns the DataContainer
func get_data_container() -> DataContainer: return _data_container


## Deletes this component localy, with out contacting the server. Usefull when handling server side delete requests
func local_delete() -> void:
	Client.remove_networked_object(_data_container.uuid)
	super.local_delete()

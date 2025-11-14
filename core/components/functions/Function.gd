# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name Function extends EngineComponent
## Base class for all functions, scenes, cuelists ect


## Emitted when the current intensity of this function changes, eg the fade position of a scene
signal intensity_changed(intensity: float)

## Emitted when the active state changes
signal active_state_changed(state: ActiveState)

## Emitted when the transport state changes
signal transport_state_changed(state: TransportState)

## Emitted when the PriorityMode state changes
signal priority_mode_state_changed(state: PriorityMode)

## Emitted when auto start is changed
signal auto_start_changed(auto_start: bool)

## Emitted when auto stop is changed
signal auto_stop_changed(auto_stop: bool)


## Active State
enum ActiveState {
	DISABLED,
	ENABLED,
}

## Transport Stae
enum TransportState {
	PAUSED,
	FORWARDS,
	BACKWARDS
}

## Priority Mode
enum PriorityMode {
	HTP,
	LTP
}

## Intensity of this function
var _intensity: float = 0

## Current ActiveState of this function
var _active_state: ActiveState = ActiveState.DISABLED

## Current TransportState of this function
var _transport_state: TransportState = TransportState.PAUSED

## The current PriorityMode
var _priority_mode: PriorityMode = PriorityMode.HTP

## Should this Function set ActiveState to ENABLED when intensity is not 0
var _auto_start: bool = true

## Should this Function set ActiveState to DISABLED when intensity is 0
var _auto_stop: bool = true

## The DataContainer used to store scene data
var _data_container: DataContainer = DataContainer.new()


## Constructor
func _init(p_uuid: String = UUID_Util.v4(), p_name: String = _name) -> void:
	_set_name("Function")
	_set_self_class("Function")
	
	register_control_method("set_intensity", set_intensity, Callable(), intensity_changed, [TYPE_FLOAT])
	register_control_method("on", on)
	register_control_method("off", off)
	register_control_method("toggle", toggle)
	register_control_method("play", play)
	register_control_method("pause", pause)
	register_control_method("temp", full, blackout)
	register_control_method("flash", on, off)
	register_control_method("full", full)
	register_control_method("blackout", blackout)
	
	register_callback("on_intensity_changed", _set_intensity)
	register_callback("on_active_state_changed", _set_active_state)
	register_callback("on_transport_state_changed", _set_transport_state)
	register_callback("on_priority_mode_state_changed", _set_priority_mode_state)
	register_callback("on_auto_start_changed", _set_auto_start)
	register_callback("on_auto_stop_changed", _set_auto_stop)
	
	#register_custom_panel("Function", "status_controls", "set_function", load("res://components/ComponentSettings/ClassCustomModules/FunctionStatusControls.tscn"))
	#register_setting_enum("priority_mode", set_priority_mode_state, get_priority_mode_state, priority_mode_state_changed, PriorityMode)
	#register_setting("Function", "auto_start", set_auto_start, get_auto_start, auto_start_changed, Utils.TYPE_BOOL, 2, "Auto Start")
	#register_setting("Function", "auto_stop", set_auto_stop, get_auto_stop, auto_stop_changed, Utils.TYPE_BOOL, 3, "Auto Stop")
	
	Client.add_networked_object(_data_container.uuid(), _data_container)
	super._init(p_uuid, p_name)


## Enables this Function
func on() -> Promise:
	return rpc("on")


## Disables this function
func off() -> Promise:
	return rpc("off")


## Toggles this scenes acive state
func toggle() -> Promise:
	return rpc("toggle")


## Sets this scenes ActiveState
func set_active_state(active_state: ActiveState) -> void:
	return rpc("set_active_state", [active_state])


## Override this function to handle ActiveState changes
func _handle_active_state_change(active_state: ActiveState) -> void:
	pass


## Gets the ActiveState
func get_active_state() -> ActiveState:
	return _active_state


## Plays this Function, with the previous TransportState
func play() -> Promise:
	return rpc("play")


## Plays this Function with TransportState.FORWARDS
func play_forwards() -> Promise:
	return rpc("play_forwards")


## Plays this Function with TransportState.BACKWARDS
func play_backwards() -> Promise:
	return rpc("play_backwards")
	

## Pauses this function
func pause() -> Promise:
	return rpc("pause")


## Sets this Function TransportState
func set_transport_state(transport_state: TransportState) -> Promise:
	return rpc("set_transport_state", [transport_state])


## Override this function to handle TransportState changes
func _handle_transport_state_chage(transport_state: TransportState) -> void:
	pass


## Gets the current TransportState
func get_transport_state() -> TransportState:
	return _transport_state


## Blackouts this Function, by setting the intensity to 0
func blackout() -> Promise:
	return rpc("blackout")


## Sets this Function at full, by setting the intensity to 1
func full() -> Promise:
	return rpc("full")


## Sets the intensity of this function, from 0.0 to 1.0
func set_intensity(p_intensity: float) -> Promise:
	return rpc("set_intensity", [p_intensity])


## Override this function to handle intensity changes
func _handle_intensity_change(p_intensity: float) -> void:
	pass


## Returnes the intensity
func get_intensity() -> float:
	return _intensity


## Sets the _priority_mode state
func set_priority_mode_state(p_priority_mode: PriorityMode) -> Promise:
	return rpc("set_priority_mode_state", [p_priority_mode])


## Gets the current PriorityMode
func get_priority_mode_state() -> PriorityMode:
	return _priority_mode


## Sets the auto start state
func set_auto_start(p_auto_start: bool) -> Promise:
	return rpc("set_auto_start", [p_auto_start])


## Gets the autostart state
func get_auto_start() -> bool:
	return _auto_start


## Sets the auto stop state
func set_auto_stop(p_auto_stop: bool) -> Promise:
	return rpc("set_auto_stop", [p_auto_stop])


## Gets the auto stop state
func get_auto_stop() -> bool:
	return _auto_stop


## Returns the DataContainer 
func get_data_container() -> DataContainer:
	return _data_container


## Internal: Sets this scenes ActiveState
func _set_active_state(active_state: ActiveState) -> void:
	if _active_state == active_state:
		return
	
	_active_state = active_state
	_handle_active_state_change(_active_state)
	
	active_state_changed.emit(_active_state)


## Internal: Sets this Function TransportState
func _set_transport_state(transport_state: TransportState) -> void:
	if _transport_state == transport_state:
		return
	
	_transport_state = transport_state
	_handle_transport_state_chage(_transport_state)
	
	transport_state_changed.emit(_transport_state)


## Internal: Sets the intensity of this function, from 0.0 to 1.0
func _set_intensity(p_intensity: float) -> void:
	if p_intensity == _intensity:
		return
	
	_intensity = p_intensity
	_handle_intensity_change(_intensity)
	
	intensity_changed.emit(_intensity)


## Interna; Sets the _priority_mode state
func _set_priority_mode_state(p_priority_mode: PriorityMode) -> void:
	if p_priority_mode == _priority_mode:
		return
	
	_priority_mode = p_priority_mode
	priority_mode_state_changed.emit(_priority_mode)


## Internal: Sets the auto start state
func _set_auto_start(p_auto_start: bool) -> void:
	if _auto_start == p_auto_start:
		return
	
	_auto_start = p_auto_start
	auto_start_changed.emit(_auto_start)


## Internal: Sets the auto stop state
func _set_auto_stop(p_auto_stop: bool) -> void:
	if _auto_stop == p_auto_stop:
		return
	
	_auto_stop = p_auto_stop
	auto_stop_changed.emit(_auto_stop)


## Returns serialized version of this component, change the mode to define if this object should be serialized for saving to disk, or for networking to clients
func serialize() -> Dictionary:
	return super.serialize().merged({
		"priority_mode": _priority_mode,
		"auto_start": _auto_start,
		"auto_stop": _auto_stop
	})


## Loades this object from a serialized version
func load(p_serialized_data: Dictionary) -> void:
	_set_priority_mode_state(type_convert(p_serialized_data.get("priority_mode", _priority_mode), TYPE_INT))

	_auto_start = type_convert(p_serialized_data.get("auto_start", _auto_start), TYPE_BOOL)
	_auto_stop = type_convert(p_serialized_data.get("auto_stop", _auto_stop), TYPE_BOOL)
	
	if "intensity" in p_serialized_data:
		_intensity = type_convert(p_serialized_data.get("intensity", _intensity), TYPE_FLOAT)
		
	if "active_state" in p_serialized_data:
		_active_state = type_convert(p_serialized_data.get("active_state", _active_state), TYPE_INT)
	
	if "transport_state" in p_serialized_data:
		_transport_state = type_convert(p_serialized_data.get("transport_state", _transport_state), TYPE_INT)
	
	super.load(p_serialized_data)


## Deletes this component localy, with out contacting the server. Usefull when handling server side delete requests
func local_delete() -> void:
	Client.remove_networked_object(_data_container.uuid())
	super.local_delete()

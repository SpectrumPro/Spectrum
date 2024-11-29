# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name InputTrigger extends RefCounted
## Triggers MethodTriggers when inputs are recieved


## Trigger for button down events
var down_trigger: MethodTrigger = MethodTrigger.new()

## Trigger for up events
var up_trigger: MethodTrigger = MethodTrigger.new()

## The trigger for value based events
var value_trigger: MethodTrigger = MethodTrigger.new()

## Remap settings for the value trigger
var value_remap: Array = []


## The last value send to the value trigger
var _previous_value: float = INF


## Triggers the down trigger
func down() -> void: down_trigger.call_method()

## Triggers the up trigger
func up() -> void: up_trigger.call_method()

## Triggers the value trigger
func value(value: float) -> void:
	var new_value: float = 0
	
	if len(value_remap) == 4:
		new_value = snapped(remap(value, value_remap[0], value_remap[1], value_remap[2], value_remap[3]), 0.001)
	else:
		new_value = value 
	
	if new_value != _previous_value:
		value_trigger.call_method([new_value])
	
	_previous_value = new_value


## Saves this MethodTrigger into a dictionary
func seralize() -> Dictionary:
	return {
		"down": down_trigger.seralize(),
		"up": up_trigger.seralize()
	}


## Loads this MethodTrigger from a dictionary
func deseralize(seralized_data: Dictionary) -> InputTrigger:
	if seralized_data.has("up"): up_trigger.deseralize(seralized_data.up)
	if seralized_data.has("down"): down_trigger.deseralize(seralized_data.down)
	
	if seralized_data.has("value"): value_trigger.deseralize(seralized_data.value)
	if seralized_data.has("value_config"): 
		if seralized_data.value_config.has("remap"): value_remap = (seralized_data.value_config.remap as Array)
	
	return self

# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name InputTrigger extends RefCounted
## Triggers MethodTriggers when inputs are recieved


## Trigger for button down events
var down_trigger: MethodTrigger = MethodTrigger.new()

## Trigger for up events
var up_trigger: MethodTrigger = MethodTrigger.new()


## Triggers the down trigger
func down() -> void: down_trigger.call_method()

## Triggers the up trigger
func up() -> void: up_trigger.call_method()


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
	
	return self

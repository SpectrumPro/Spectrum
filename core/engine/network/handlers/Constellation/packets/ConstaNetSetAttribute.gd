# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name ConstaNetSetAttribute extends ConstaNetHeadder
## ConstaNET Set Arrtibute packet


## Attribute Enum
enum Attribute {
	UNKNOWN,		## Default State
	NAME,			## Sets the name of a device
	IP_ADDR,		## Sets the Ip Address of a supported device
	SESSION,		## Tells the device to join the given session
}


## Type of attribute
var attribute: Attribute

## The value
var value: String = ""


## Init
func _init() -> void:
	type = Type.SET_ATTRIBUTE


## Gets this ConstaNetDiscovery as a Dictionary
func _get_as_dict() -> Dictionary[String, Variant]:
	return {
		"attribute": attribute,
		"value": value
	}


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	attribute = type_convert(p_dict.get("attribute", 0), TYPE_INT)
	value = type_convert(p_dict.get("value", ""), TYPE_STRING)


## Checks if this ConstaNetDiscovery is valid
func _is_valid() -> bool:
	if attribute:
		return true
	
	return false

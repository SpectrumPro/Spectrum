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


## Gets this ConstaNetSetAttribute as a Dictionary
func _get_as_dict() -> Dictionary[String, Variant]:
	return {
		"attribute": attribute,
		"value": value
	}


## Gets this ConstaNetSetAttribute as a PackedByteArray
func _get_as_packet() -> PackedByteArray:
	var result: PackedByteArray = PackedByteArray()
	
	result.append_array(ba(attribute, 2))
	
	var value_bytes: PackedByteArray = value.to_ascii_buffer()
	result.append_array(ba(value_bytes.size(), 2))
	result.append_array(value_bytes)
	
	return result


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	attribute = type_convert(p_dict.get("attribute", 0), TYPE_INT)
	value = type_convert(p_dict.get("value", ""), TYPE_STRING)


## Phrases a PackedByteArray
func _phrase_packet(p_packet: PackedByteArray) -> void:
	if p_packet.size() < 4:
		return
	
	var offset: int = 0
	var value_size: int = 0
	
	attribute = ba_to_int(p_packet, offset, 2)
	offset += 2
	
	value_size = ba_to_int(p_packet, offset, 2)
	offset += 2
	
	if p_packet.size() < offset + value_size:
		return
	
	value = p_packet.slice(offset, offset + value_size).get_string_from_ascii()
	offset += value_size


## Checks if this ConstaNetDiscovery is valid
func _is_valid() -> bool:
	if attribute:
		return true
	
	return false

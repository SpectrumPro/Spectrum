
# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name ConstaNetGoodbye extends ConstaNetHeadder
## ConstaNET Goodbye packet


## Reason for this node going offlin
var reason: String = "Unknown"


## Init
func _init() -> void:
	type = Type.GOODBYE


## Gets this ConstaNetGoodbye as a Dictionary
func _get_as_dict() -> Dictionary[String, Variant]:
	return {
		"reason": reason,
	}


## Gets this ConstaNetGoodbye as a PackedByteArray
func _get_as_packet() -> PackedByteArray:
	var result: PackedByteArray = PackedByteArray()
	var reason_bytes: PackedByteArray = reason.to_ascii_buffer()
	
	result.append_array(ba(reason_bytes.size(), 2))
	result.append_array(reason_bytes)
	
	return result


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	reason = type_convert(p_dict.get("reason", ""), TYPE_STRING)


## Phrases a PackedByteArray
func _phrase_packet(p_packet: PackedByteArray) -> void:
	if p_packet.size() < 2:
		return
	
	var offset: int = 0
	var reason_size: int = ba_to_int(p_packet, offset, 2)
	offset += 2
	
	if p_packet.size() < offset + reason_size:
		return
	
	reason = p_packet.slice(offset, offset + reason_size).get_string_from_ascii()
	offset += reason_size


## Checks if this ConstaNetGoodbye is valid
func _is_valid() -> bool:
	return true

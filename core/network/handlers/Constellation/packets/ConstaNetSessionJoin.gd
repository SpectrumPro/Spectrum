# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name ConstaNetSessionJoin extends ConstaNetHeadder
## ConstaNET Session Join message


## The UUID of this session
var session_id: String


## Init
func _init() -> void:
	type = Type.SESSION_JOIN


## Gets this ConstaNetSessionJoin as a Dictionary
func _get_as_dict() -> Dictionary[String, Variant]:
	return {
		"id": session_id,
	}


## Gets this ConstaNetSessionJoin as a PackedByteArray
func _get_as_packet() -> PackedByteArray:
	var result: PackedByteArray = PackedByteArray()
	
	result.append_array(get_id_as_buffer(session_id))
	
	return result


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	session_id = type_convert(p_dict.get("id", ""), TYPE_STRING)


## Phrases a PackedByteArray
func _phrase_packet(p_packet: PackedByteArray) -> void:
	if p_packet.size() < NODE_ID_LENGTH:
		return
	
	var offset: int = 0
	
	session_id = p_packet.slice(offset, offset + NODE_ID_LENGTH).get_string_from_ascii()
	offset += NODE_ID_LENGTH


## Checks if this ConstaNetSessionJoin is valid
func _is_valid() -> bool:
	if session_id:
		return true
	
	return false

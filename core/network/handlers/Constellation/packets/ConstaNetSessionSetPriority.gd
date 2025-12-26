# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name ConstaNetSessionSetPriority extends ConstaNetHeadder
## ConstaNET Session Set Priority message


## The UUID of this session
var session_id: String

## The NodeId of the node to move
var node_id: String

## The position in the order to move it to
var position: int = - 1


## Init
func _init() -> void:
	type = Type.SESSION_SET_PRIORITY


## Gets this ConstaNetSessionSetPriority as a Dictionary
func _get_as_dict() -> Dictionary[String, Variant]:
	return {
		"id": session_id,
		"node_id": node_id,
		"position": position
	}


## Gets this ConstaNetSessionSetMaster as a PackedByteArray
func _get_as_packet() -> PackedByteArray:
	var result: PackedByteArray = PackedByteArray()
	
	result.append_array(get_id_as_buffer(session_id))
	result.append_array(get_id_as_buffer(node_id))
	result.append_array(ba(position, 2))
	
	return result


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	session_id = type_convert(p_dict.get("id", ""), TYPE_STRING)
	node_id = type_convert(p_dict.get("node_id", ""), TYPE_STRING)
	position = type_convert(p_dict.get("position", -1), TYPE_INT)


## Phrases a PackedByteArray
func _phrase_packet(p_packet: PackedByteArray) -> void:
	if p_packet.size() < NODE_ID_LENGTH + NODE_ID_LENGTH + 2:
		return
	
	var offset: int = 0
	
	session_id = p_packet.slice(offset, offset + NODE_ID_LENGTH).get_string_from_ascii()
	offset += NODE_ID_LENGTH
	
	node_id = p_packet.slice(offset, offset + NODE_ID_LENGTH).get_string_from_ascii()
	offset += NODE_ID_LENGTH
	
	position = ba_to_int(p_packet, offset, 2)
	offset += 2


## Checks if this ConstaNetSessionSetPriority is valid
func _is_valid() -> bool:
	if session_id and node_id and position >= 0:
		return true
	
	return false

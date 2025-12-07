
# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name ConstaNetSessionAnnounce extends ConstaNetHeadder
## ConstaNET Session Announce message


## The SessionID of this session
var session_id: String

## NodeID of the session master
var session_master: String

## The name of the session
var session_name: String

## All NodeIDs in this session
var nodes: Array[String]


## Init
func _init() -> void:
	type = Type.SESSION_ANNOUNCE


## Gets this ConstaNetSessionJoin as a Dictionary
func _get_as_dict() -> Dictionary[String, Variant]:
	return {
		"session_id": session_id,
		"session_master": session_master,
		"session_name": session_name,
		"nodes": nodes
	}


## Gets this ConstaNetSessionJoin as a PackedByteArray
func _get_as_packet() -> PackedByteArray:
	var result: PackedByteArray = PackedByteArray()
	
	result.append_array(get_id_as_buffer(session_id))
	result.append_array(get_id_as_buffer(session_master))
	
	var name_bytes: PackedByteArray = session_name.to_ascii_buffer()
	
	result.append_array(ba(name_bytes.size(), 2))
	result.append_array(name_bytes)
	
	result.append_array(ba(nodes.size(), 2))
	for node_id: String in nodes:
		result.append_array(get_id_as_buffer(node_id))
	
	return result


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	session_id = type_convert(p_dict.get("session_id", ""), TYPE_STRING)
	session_master = type_convert(p_dict.get("session_master", ""), TYPE_STRING)
	session_name = type_convert(p_dict.get("session_name", ""), TYPE_STRING)
	
	var p_nodes: Array = type_convert(p_dict.get("nodes", []), TYPE_ARRAY)
	for node: Variant in p_nodes:
		nodes.append(str(node))


## Phrases a PackedByteArray
func _phrase_packet(p_packet: PackedByteArray) -> void:
	if p_packet.size() < NODE_ID_LENGTH + NODE_ID_LENGTH + 2:
		return
	
	var offset: int = 0
	
	session_id = p_packet.slice(offset, offset + NODE_ID_LENGTH).get_string_from_ascii()
	offset += NODE_ID_LENGTH
	
	session_master = p_packet.slice(offset, offset + NODE_ID_LENGTH).get_string_from_ascii()
	offset += NODE_ID_LENGTH
	
	var name_size: int = ba_to_int(p_packet, offset, 2)
	offset += 2
	
	if p_packet.size() < offset + name_size + 2:
		return
	
	session_name = p_packet.slice(offset, offset + name_size).get_string_from_ascii()
	offset += name_size
	
	var num_of_nodes: int = ba_to_int(p_packet, offset, 2)
	offset += 2
	
	if p_packet.size() < offset + (NODE_ID_LENGTH * num_of_nodes):
		return
	
	for index: int in range(0, num_of_nodes):
		nodes.append(p_packet.slice(offset, offset + NODE_ID_LENGTH).get_string_from_ascii())
		offset += NODE_ID_LENGTH


## Checks if this ConstaNetSessionJoin is valid
func _is_valid() -> bool:
	if session_id:
		return true
	
	return false

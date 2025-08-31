
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


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	session_id = type_convert(p_dict.get("session_id", ""), TYPE_STRING)
	session_master = type_convert(p_dict.get("session_master", ""), TYPE_STRING)
	session_name = type_convert(p_dict.get("session_name", ""), TYPE_STRING)
	
	var p_nodes: Array = type_convert(p_dict.get("nodes", []), TYPE_ARRAY)
	for node: Variant in p_nodes:
		nodes.append(str(node))


## Checks if this ConstaNetSessionJoin is valid
func _is_valid() -> bool:
	if session_id:
		return true
	
	return false

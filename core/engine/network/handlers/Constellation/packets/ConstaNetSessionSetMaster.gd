
# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name ConstaNetSessionSetMaster extends ConstaNetHeadder
## ConstaNET Session Set Master message


## The UUID of this session
var session_id: String

## The NodeId of the node to make the master
var node_id: String


## Init
func _init() -> void:
	type = Type.SESSION_SET_MASTER


## Gets this ConstaNetSessionSetMaster as a Dictionary
func _get_as_dict() -> Dictionary[String, Variant]:
	return {
		"id": session_id,
		"node_id": node_id,
	}


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	session_id = type_convert(p_dict.get("id", ""), TYPE_STRING)
	node_id = type_convert(p_dict.get("node_id", ""), TYPE_STRING)


## Checks if this ConstaNetSessionSetMaster is valid
func _is_valid() -> bool:
	if session_id and node_id:
		return true
	
	return false

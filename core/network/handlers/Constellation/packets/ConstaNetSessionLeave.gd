
# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name ConstaNetSessionLeave extends ConstaNetHeadder
## ConstaNET Session Join message


## The UUID of this session
var session_id: String


## Init
func _init() -> void:
	type = Type.SESSION_LEAVE


## Gets this ConstaNetSessionJoin as a Dictionary
func _get_as_dict() -> Dictionary[String, Variant]:
	return {
		"id": session_id,
	}


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	session_id = type_convert(p_dict.get("id", ""), TYPE_STRING)


## Checks if this ConstaNetSessionLeave is valid
func _is_valid() -> bool:
	if session_id:
		return true
	
	return false

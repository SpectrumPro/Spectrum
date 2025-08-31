
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


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	reason = type_convert(p_dict.get("reason", ""), TYPE_STRING)


## Checks if this ConstaNetGoodbye is valid
func _is_valid() -> bool:
	return true

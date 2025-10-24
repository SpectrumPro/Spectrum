
# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name ConstaNetCommand extends ConstaNetHeadder
## ConstaNET Command packet


## Datatype of the command
var data_type: int = TYPE_NIL

## Command to send
var command: Variant

## SessionID this command is for
var in_session: String


## Init
func _init() -> void:
	type = Type.COMMAND


## Gets this ConstaNetCommand as a Dictionary
func _get_as_dict() -> Dictionary[String, Variant]:
	return {
		"data_type": data_type,
		"command": var_to_str(command),
		"in_session": in_session
	}


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	data_type = type_convert(p_dict.get("data_type", 0), TYPE_INT)
	command = type_convert(str_to_var(p_dict.get("command", "")), data_type)
	in_session = type_convert(p_dict.get("in_session", ""), TYPE_STRING)


## Checks if this ConstaNetCommand is valid
func _is_valid() -> bool:
	if command and data_type and typeof(command) == data_type:
		return true
	
	else:
		return false

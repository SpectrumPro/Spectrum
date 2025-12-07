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


## Gets this ConstaNetCommand as a PackedByteArray
func _get_as_packet() -> PackedByteArray:
	var result: PackedByteArray = PackedByteArray()
	var command_bytes: PackedByteArray = var_to_bytes(command)
	
	result.append_array(ba(data_type, 2))
	result.append_array(ba(command_bytes.size(), 4))
	result.append_array(command_bytes)
	result.append_array(get_id_as_buffer(in_session))
	
	return result


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	data_type = type_convert(p_dict.get("data_type", 0), TYPE_INT)
	command = type_convert(str_to_var(p_dict.get("command", "")), data_type)
	in_session = type_convert(p_dict.get("in_session", ""), TYPE_STRING)


## Phrases a PackedByteArray
func _phrase_packet(p_packet: PackedByteArray) -> void:
	if p_packet.size() < 6:
		return
	
	var offset: int = 0
	var command_length: int = 0
	 
	data_type = ba_to_int(p_packet, offset, 2)
	offset += 2
	
	command_length = ba_to_int(p_packet, offset, 4)
	offset += 4
	
	if p_packet.size() < offset + command_length:
		return
	
	command = type_convert(bytes_to_var(p_packet.slice(offset, offset + command_length)), data_type)
	offset += command_length
	
	if p_packet.size() < offset + NODE_ID_LENGTH:
		return
	
	in_session = p_packet.slice(offset, offset + NODE_ID_LENGTH).get_string_from_ascii()
	offset += NODE_ID_LENGTH


## Checks if this ConstaNetCommand is valid
func _is_valid() -> bool:
	if command and data_type and typeof(command) == data_type:
		return true
	
	else:
		return false

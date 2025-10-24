# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name ConstaNetHeadder extends RefCounted
## Base ConstsNetHeadder class for ConstaNET headders


## Current proto version
const VERSION: int = 1

## Type Enum
enum Type {
	UNKNOWN, 				# Init base state
	
	DISCOVERY,				# Client/server broadcasts "Who’s there?"
	GOODBYE,				# Node going offline
	COMMAND,				# Lighting cue or control command
	
	SET_ATTRIBUTE,			# Sets an attribute on a node, name, ipaddress, ect..
	STATE_REQUEST,			# Request full state sync
	HEARTBEAT,				# Periodic alive signal
	
	SESSION_ANNOUNCE,		# Announces a new session
	SESSION_DISCOVERY,		# Requests network nodes to anounce sessions
	SESSION_JOIN,			# New node joining a session
	SESSION_LEAVE,			# Node leaving a session
	SESSION_SET_PRIORITY,	# Sets the fail over proirity of a node
	SESSION_SET_MASTER,		# Sets the master of the session
	
	SYS_EXCLUSIVE			# Device/vendor specific or extended data
}

## Flags Enum (bitmask-compatible)
enum Flags {
	NONE				= 0,		# Default state
	REQUEST				= 1 << 0,	# This message is requesting a responce
	ACKNOWLEDGMENT		= 1 << 1,	# This message is responding to a request
	ERROR				= 1 << 2,	# This message contains an error
	ANNOUNCEMENT		= 1 << 3,	# This message contains new or updated infomation
	RETRANSMISSION		= 1 << 4,	# This message has been re-transmitted from a RelayServer
}

## Enum for network roles
enum RoleFlags {
	NONE				= 0,
	EXECUTOR			= 1 << 0,	# Performs the actions defined by the Controller
	CONTROLLER			= 1 << 1,	# # Sends control and command messages to the Executer 
}


## Matches the Type enum to a class
static var ClassTypes: Dictionary[int, Script] = {
	Type.UNKNOWN: ConstaNetHeadder,
	Type.DISCOVERY: ConstaNetDiscovery,
	Type.GOODBYE: ConstaNetGoodbye,
	Type.COMMAND: ConstaNetCommand,
	Type.SET_ATTRIBUTE: ConstaNetSetAttribute,
	Type.SESSION_ANNOUNCE: ConstaNetSessionAnnounce,
	Type.SESSION_DISCOVERY: ConstaNetSessionDiscovery,
	Type.SESSION_JOIN: ConstaNetSessionJoin,
	Type.SESSION_LEAVE: ConstaNetSessionLeave,
	Type.SESSION_SET_PRIORITY: ConstaNetSessionSetPriority,
	Type.SESSION_SET_MASTER: ConstaNetSessionSetMaster
}


## The type of this ConstaNET packet
var type: Type = Type.UNKNOWN

## Flags for this ConstaNET packet
var flags: Flags = Flags.NONE

## The UUID for the origin node 
var origin_id: String = ""

## The UUID for the target node
var target_id: String

## Version number of the orignal message
var _origin_version: int = 0


## Gets this ConstaNETHeadder as a Dictionary
func get_as_dict() -> Dictionary[String, Variant]:
	return _get_as_dict().merged({
		"version": VERSION,
		"type": type,
		"flags": flags,
		"origin_id": origin_id,
		"target_id": target_id
	})


## Gets this ConstaNETHeadder as a String
func get_as_string() -> String:
	return str(get_as_dict())


## Gets this ConstaNetHeadder as a PackedByteArray
func get_as_packet() -> PackedByteArray:
	return get_as_string().to_utf8_buffer()


## Returns true if this ConstaNet message is valid
func is_valid() -> bool:
	if not type or not origin_id or _origin_version != VERSION:
		return false
	
	return _is_valid()


## Sets this ConstaNet message's Request flag
func set_request(p_state: bool) -> void:
	if p_state:
		flags |= Flags.REQUEST
	else:
		flags &= ~Flags.REQUEST


## Sets this ConstaNet message's Acknowledgment flag
func set_acknowledgment(p_state: bool) -> void:
	if p_state:
		flags |= Flags.ACKNOWLEDGMENT
	else:
		flags &= ~Flags.ACKNOWLEDGMENT


## Sets this ConstaNet message's Error flag
func set_error(p_state: bool) -> void:
	if p_state:
		flags |= Flags.ERROR
	else:
		flags &= ~Flags.ERROR


## Sets this ConstaNet message's Announcement flag
func set_announcement(p_state: bool) -> void:
	if p_state:
		flags |= Flags.ANNOUNCEMENT
	else:
		flags &= ~Flags.ANNOUNCEMENT


## Sets this ConstaNet message's Retransmission flag
func set_retransmission(p_state: bool) -> void:
	if p_state:
		flags |= Flags.RETRANSMISSION
	else:
		flags &= ~Flags.RETRANSMISSION


## Returns true if the Request flag is set
func is_request() -> bool:
	return (flags & Flags.REQUEST) != 0


## Returns true if the Acknowledgment flag is set
func is_acknowledgment() -> bool:
	return (flags & Flags.ACKNOWLEDGMENT) != 0


## Returns true if the Error flag is set
func is_error() -> bool:
	return (flags & Flags.ERROR) != 0


## Returns true if the Announcement flag is set
func is_announcement() -> bool:
	return (flags & Flags.ANNOUNCEMENT) != 0


## Returns true if the Retransmission flag is set
func is_retransmission() -> bool:
	return (flags & Flags.RETRANSMISSION) != 0


## Phrases a Dictionary
static func phrase_dict(p_dict: Dictionary) -> ConstaNetHeadder:
	var message: ConstaNetHeadder
	
	var p_origin_version: int = type_convert(p_dict.get("version", 0), TYPE_INT)
	var p_type: int = type_convert(p_dict.get("type", 0), TYPE_INT)
	var p_flags: int = type_convert(p_dict.get("flags", 0), TYPE_INT)
	var p_origin_id: String = type_convert(p_dict.get("origin_id", ""), TYPE_STRING)
	var p_target_id: String = type_convert(p_dict.get("target_id", ""), TYPE_STRING)
	
	if p_type not in ClassTypes:
		return ConstaNetHeadder.new()
	
	message = ClassTypes[p_type].new()
	message._origin_version = p_origin_version
	message.type = p_type
	message.flags = p_flags
	message.origin_id = p_origin_id
	message.target_id = p_target_id
	
	message._phrase_dict(p_dict)
	
	return message


## Phrases a String
static func phrase_string(p_string: String) -> ConstaNetHeadder:
	if not p_string:
		return ConstaNetHeadder.new()
	
	var data: Variant = JSON.parse_string(p_string)
	
	if not data:
		return ConstaNetHeadder.new()
	
	return phrase_dict(data)


## Override this function to provide a method to get the packet as a Dictionary
func _get_as_dict() -> Dictionary[String, Variant]:
	return {}


## Override this function to provide a method to phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	pass


## Override this function to provide a method to check if its a valid message
func _is_valid() -> bool:
	return false

# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name NetworkSession extends NetworkItem
## Base class for all NetworkSessions

@warning_ignore_start("unused_signal")

## Emitted when a node joins the session
signal node_joined(node: NetworkNode)

## Emitted when a node leaves the session
signal node_left(node: NetworkNode)

## Emitted when the session master is changes
signal master_changed(node: NetworkNode)

## Emitted when the priority order of a node is changed
signal priority_changed(node: NetworkNode, position: int)


## Enum for session flags
enum SessionFlags {
	NONE				= 0,		## Default state
	UNKNOWN				= 1 << 0,	## This node is a unknown session
}

## Enum for the node filter
enum NodeFilter {
	NONE,				## Default State
	MASTER,				## Send only to the session master
	ALL_NODES,			## Send to all nodes
	ALL_OTHER_NODES,	## Send to all nodes, expect the session master
	MANUAL,				## Manualy specify a list of nodes to send to
}


## The SettingsManager for this 
var settings_manager: SettingsManager = SettingsManager.new()

## The current SessionMaster
var _session_master: NetworkNode

## The name of this session
var _name: String = "UnNamed ConstellationSession"

## Session Flags
var _session_flags: int = SessionFlags.NONE


## Creates a new unknown session
static func create_unknown_session(p_session_id: String) -> NetworkSession:
	var session: NetworkSession = NetworkSession.new()
	
	session._mark_as_unknown(true)
	session._set_name("UnknownSession")
	
	return session


## Sets the position of a node in the priority order
func set_priority_order(p_node: NetworkNode, p_position: int) -> bool:
	return false


## Sets the session master
func set_master(p_node: NetworkNode) -> bool:
	return false


## Gets all nodes in this session
func get_nodes() -> Array[NetworkNode]:
	return []


## Shorthand to get the number of nodes in this session
func get_number_of_nodes() -> int:
	return 0


## Returns the current SessionMaster
func get_session_master() -> NetworkNode:
	return _session_master


## Returns the priority order
func get_priority_order() -> Array[NetworkNode]:
	return []


## Returns the priority order
func get_priority_of(p_node: NetworkNode) -> int:
	return 0


## Gets the session name
func get_session_name() -> String:
	return _name


## Gets the session flags
func get_session_flags() -> int:
	return _session_flags


## Returns true if this session has a master
func has_session_master() -> bool:
	return _session_master != null


## Closes this sessions local object
func close() -> void:
	pass


## Sends a command to the session, using p_node_filter as the NodeFilter
func send_command(p_command: Variant, p_node_filter: NodeFilter = NodeFilter.MASTER) -> Error:
	return ERR_UNAVAILABLE


## Sends a pre-existing ConstaNetCommand message to the session
func send_pre_existing_command(p_command: ConstaNetCommand, p_node_filter: NodeFilter = NodeFilter.MASTER) -> Error:
	return ERR_UNAVAILABLE


## Sets the SessionName
func _set_name(p_name: String) -> bool:
	if p_name == _name:
		return false
	
	_name = p_name
	return true


## Marks or unmarks this node as unknown
func _mark_as_unknown(p_unknown: bool) -> void:
	if p_unknown:
		_session_flags |= SessionFlags.UNKNOWN
	else:
		_session_flags &= ~SessionFlags.UNKNOWN

# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name NetworkHandler extends Node
## Base class for all NetworkHandlers


## Emitted when a NetworkNode is found
signal node_found(node: NetworkNode)

## Emitted when a NetworkSession is created
signal session_created(session: NetworkSession)

## Emitted when the NetworkState is changed
signal network_state_changed(network_state: NetworkState, err_code: Error)


## Enum for NetworkState
enum NetworkState {
	OFFLINE,			## Default offline state
	INITIALIZING, 		## Handler is getting ready to bind
	BOUND,				## Handler has bound network ports
	READY,				## Handler is ready for comms
	ERROR				## Handler has had an error
}


## The current NetworkState
var _network_state: NetworkState = NetworkState.OFFLINE

## Previous error code of the NetworkState
var _network_state_err_code: Error = FAILED


## Starts the local node
func start_node() -> Error:
	return ERR_UNAVAILABLE


## Stops the local node
func stop_node(p_internal_only: bool = false) -> Error:
	return ERR_UNAVAILABLE


## Creates and joins a new session
func create_session(p_name: String) -> NetworkSession:
	return null


## Joins a pre-existing session on the network
func join_session(p_session: NetworkSession) -> bool:
	return false


## Leaves a session 
func leave_session() -> bool:
	return false


## Gets the current NetworkState
func get_network_state() -> NetworkState:
	return _network_state


## Gets the current NetworkState error code
func get_network_state_err_code() -> Error:
	return _network_state_err_code


## Returns all known NetworkNodes
func get_known_nodes() -> Array[NetworkNode]:
	return []


## Returns all unknown NetworkNodes
func get_unknown_nodes() -> Array[NetworkNode]:
	return []


## Returns all known NetworkSessions
func get_known_sessions() -> Array[NetworkSession]:
	return []


## Returns all unknown NetworkSessions
func get_unknown_sessions() -> Array[NetworkSession]:
	return []

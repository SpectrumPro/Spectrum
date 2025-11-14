# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name ConstellationSession extends NetworkSession
## Class to repersent a session


## The Constellation NetworkHandler
static var _network: Constellation = null

## All nodes in this session
var _nodes: Array[ConstellationNode]

## The SessionID of this session
var _session_id: String = UUID_Util.v4()

## Priority order
var _priority_order: Array[ConstellationNode]

## SignalGroup for all nodes
var _node_connections: SignalGroup = SignalGroup.new([
	_on_node_connection_state_changed
]).set_prefix("_on_node_")


## Creates a new session from a ConstaNetSessionAnnounce message
static func create_from_session_announce(p_message: ConstaNetSessionAnnounce) -> ConstellationSession:
	var session: ConstellationSession = ConstellationSession.new()
	
	session._set_session_id(p_message.session_id)
	session._set_name(p_message.session_name)
	
	for node_id: String in p_message.nodes:
		var node: ConstellationNode = _network.get_node_from_id(node_id, true)
		if node:
			session._add_node(node)
	
	return session


## Creates a new unknown session
static func create_unknown_session(p_session_id: String) -> ConstellationSession:
	var session: ConstellationSession = ConstellationSession.new()
	
	session._set_session_id(p_session_id)
	session._mark_as_unknown(true)
	session._set_name("UnknownSession")
	
	return session


## Init
func _init() -> void:
	settings_manager.register_setting("Master", Data.Type.NETWORKNODE, set_master, get_session_master, [master_changed]).set_class_filter(ConstellationNode)
	settings_manager.register_status("Name", Data.Type.NAME, get_session_name, [])
	settings_manager.register_status("MemberCount", Data.Type.INT, get_number_of_nodes, [node_joined, node_left])


## Updates the details of this node with a ConstaNetSessionAnnounce message
func update_with(p_message: ConstaNetSessionAnnounce) -> bool:
	if _session_id != p_message.session_id:
		return false
	
	_set_session_master(_network.get_node_from_id(p_message.session_master, true))
	_set_name(p_message.session_name)
	_set_node_array(_network.get_node_array(p_message, true))
	
	return true


## Sets the position of a node in the priority order
func set_priority_order(p_node: NetworkNode, p_position: int) -> bool:
	if p_node not in _nodes:
		return false
	
	var pos: int = _set_priority_order(p_node, p_position)
	
	if pos == -1:
		return false
	
	var message: ConstaNetSessionSetPriority = ConstaNetSessionSetPriority.new()
	
	message.session_id = _session_id
	message.node_id = p_node.get_node_id()
	message.position = pos
	message.origin_id = _network.get_node_id()
	message.set_announcement(true)
	
	_network._send_message_broadcast(message)
	return true


## Sets the session master
func set_master(p_node: NetworkNode) -> bool:
	if not _set_session_master(p_node):
		return false
	
	var message: ConstaNetSessionSetMaster = ConstaNetSessionSetMaster.new()
	
	message.session_id = _session_id
	message.node_id = p_node.get_node_id()
	message.origin_id = _network.get_node_id()
	message.set_announcement(true)
	
	_network._send_message_broadcast(message)
	return true


## Gets all nodes in this session
func get_nodes() -> Array[NetworkNode]:
	var return_value: Array[NetworkNode]
	return_value.assign(_nodes)
	
	return return_value


## Shorthand to get the number of nodes in this session
func get_number_of_nodes() -> int:
	return len(_nodes)


## Gets the SessionID
func get_session_id() -> String:
	return _session_id


## Returns the current SessionMaster
func get_session_master() -> ConstellationNode:
	return _session_master


## Returns the priority order
func get_priority_order() -> Array[NetworkNode]:
	var return_value: Array[NetworkNode]
	return_value.assign(_priority_order)
	
	return return_value


## Returns the priority order
func get_priority_of(p_node: NetworkNode) -> int:
	return _priority_order.find(p_node)



## Gets the session flags
func get_session_flags() -> int:
	return _session_flags


## Returns true if this session has a master
func has_session_master() -> bool:
	return _session_master != null


## Closes this sessions local object
func close() -> void:
	_set_session_master(null)
	
	for node: ConstellationNode in _nodes.duplicate():
		_remove_node(node)
		_node_connections.disconnect_object(node, true)
	
	_priority_order.clear()
	_nodes.clear()


## Sends a command to the session, using p_node_filter as the NodeFilter
func send_command(p_command: Variant, p_node_filter: NodeFilter = NodeFilter.AUTO, p_nodes: Array[NetworkNode] = []) -> Error:
	var message: ConstaNetCommand = ConstaNetCommand.new()
	
	message.command = p_command
	message.data_type = typeof(p_command)
	
	return send_pre_existing_command(message, p_node_filter, p_nodes)


## Sends a pre-existing ConstaNetCommand message to the session
func send_pre_existing_command(p_command: ConstaNetCommand, p_node_filter: NodeFilter = NodeFilter.AUTO, p_nodes: Array[NetworkNode] = []) -> Error:
	var local_node: ConstellationNode = _network.get_local_node()
	p_command.in_session = _session_id
	p_command.origin_id = local_node.get_node_id()
	
	if p_node_filter == NodeFilter.AUTO:
		if _session_master == local_node:
			p_node_filter = NodeFilter.ALL_OTHER_NODES
		else:
			p_node_filter = NodeFilter.MASTER
	
	match p_node_filter:
		NodeFilter.MASTER:
			if _session_master == local_node:
				local_node.handle_message(p_command)
				return OK
			
			elif has_session_master():
				p_command.target_id = _session_master.get_node_id()
				return _session_master.send_message_udp(p_command)
			
			else:
				return ERR_DOES_NOT_EXIST
			
		NodeFilter.ALL_NODES:
			for node: ConstellationNode in _nodes:
				p_command.target_id = node.get_node_id()
				node.send_message_udp(p_command)
			
			return OK
			
		
		NodeFilter.ALL_OTHER_NODES:
			for node: ConstellationNode in _nodes:
				if node == local_node:
					continue
				
				p_command.target_id = node.get_node_id()
				node.send_message_udp(p_command)
				
			return OK
		
		_:
			return ERR_INVALID_PARAMETER


## Sets the SessionID
func _set_session_id(p_session_id: String) -> bool:
	if p_session_id == _session_id:
		return false
	
	_session_id = p_session_id
	return true


## Sets the session master node
func _set_session_master(p_session_master: ConstellationNode) -> bool:
	if p_session_master == _session_master or p_session_master not in _nodes:
		return false
	
	if _session_master:
		_session_master._remove_session_master_mark()
	
	_session_master = p_session_master
	
	if _session_master:
		_session_master._mark_as_session_master()
		
	master_changed.emit(_session_master)
	
	return true


## Sets the node array, and emits signals
func _set_node_array(p_node_array: Array[ConstellationNode]) -> void:
	var new_nodes: Array[ConstellationNode] = p_node_array.duplicate()
	
	for current_node: ConstellationNode in _nodes.duplicate():
		if current_node in new_nodes:
			new_nodes.erase(current_node)
		
		else:
			_remove_node(current_node, true)
	
	for new_node: ConstellationNode in new_nodes:
		_add_node(new_node)


## Internal function to Set the position of a node in the priority order
func _set_priority_order(p_node: ConstellationNode, p_position: int) -> int:
	if p_position > len(_priority_order) - 1:
		return -1
	
	_priority_order.remove_at(_priority_order.find(p_node))
	_priority_order.insert(p_position, p_node)
	
	var position: int = _priority_order.find(p_node)
	
	priority_changed.emit(p_node, position)
	return position


## Adds a node into this session
func _add_node(p_node: ConstellationNode) -> bool:
	if p_node in _nodes:
		return false
	
	_nodes.append(p_node)
	_priority_order.append(p_node)
	_node_connections.connect_object(p_node, true)
	
	node_joined.emit(p_node)
	p_node._set_session_no_join(self)
	
	if not _session_master and _priority_order[0] == p_node:
		_set_session_master(p_node)
	
	return true


## Removes a node from this session
func _remove_node(p_node: ConstellationNode, p_no_delete: bool = false) -> bool:
	if p_node not in _nodes:
		return false
	
	_nodes.erase(p_node)
	
	if not get_number_of_nodes() and not p_no_delete:
		node_left.emit(p_node)
		request_delete.emit()
		
		return true
	
	else:
		_priority_order.erase(p_node)
		_node_connections.disconnect_object(p_node, true)
		
		if p_node == _session_master:
			_set_session_master(_priority_order[0] if _priority_order else null)
		
		node_left.emit(p_node)
	
	return true


## Called when the ConnectionState changes on any node in this session
func _on_node_connection_state_changed(p_connection_state: ConstellationNode.ConnectionState, p_node: ConstellationNode) -> void:
	if _network.get_local_node() not in _nodes:
		return
	
	prints(p_node.get_node_name(), "Connection State Changed To:", ConstellationNode.ConnectionState.keys()[p_connection_state], "In Sesion", get_name(), "From Node:", _network.get_local_node().get_node_name())
	
	match p_connection_state:
		ConstellationNode.ConnectionState.UNKNOWN, ConstellationNode.ConnectionState.DISCOVERED, ConstellationNode.ConnectionState.LOST_CONNECTION:
			_priority_order.erase(p_node)
			
			if p_node == _session_master:
				_set_session_master(_priority_order[0] if _priority_order else null)

# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name Constellation extends NetworkHandler
## NetworkHandler for the Constellation Network Engine


## List of allowed host OSes to start the broadcast relay on
const BROADCAST_RELAY_ALLOWED_HOSTS: Array[String] = ["linux", "macos", "windows"]

## UDP bind port
const UDP_BROADCAST_PORT: int = 3823

## Network broadcast address
const NETWORK_BROADCAST: String = "192.168.1.255"

## Network loopback address
const NETWORK_LOOPBACK: String = "127.0.0.1"

## Time in seconds for discovery
const DISCO_TIMEOUT: int = 10

## Time in seconds for a node to be considred lost if it does not send a disco message
const DISCO_DISCONNECT_TIME: int = 12

## Wait time in seconds for a responce from from a disco broadcast
const DISCO_WAIT_TIME: int = 1

## Wait time in seconds for a responce from the relay server
const RELAY_WAIT_TIME: int = 1

## Wait time in seconds for a responce from a newley launched relay server
const RELAY_BOOT_WAIT_TIME: int = 1

## Max retry count to contact the RelayServer
const RELAY_MAX_RETRIES: int = 10

## MessageType
const MessageType: ConstaNetHeadder.Type = ConstaNetHeadder.Type

## NetworkRole
const RoleFlags: ConstaNetHeadder.RoleFlags = ConstaNetHeadder.RoleFlags

## ConstaNetGoodbye reason for going offline
const GOODBYE_REASON_GOING_OFFLINE: String = "Node Going Offline"


## ConstellationConfig object
class ConstellationConfig extends Object:
	## Disables the colorfull start up logo and copyright headder
	static var disable_startup_details: bool = false
	
	## Defines a custom callable to call when logging infomation
	static var custom_loging_method: Callable = Callable()
	
	## Defines a custom callable to call when logging infomation verbosely
	static var custom_loging_method_verbose: Callable = Callable()
	
	## A String prefix to print before all message logs
	static var log_prefix: String = ""
	
	## Loads config from a file
	static func load_config(p_path: String) -> bool:
		var script: Variant = load(p_path)
		
		if script is not GDScript or script.get("config") is not Dictionary:
			return false
		
		var config: Dictionary = script.get("config")
		
		disable_startup_details = type_convert(config.get("disable_startup_details", disable_startup_details), TYPE_BOOL)
		custom_loging_method = type_convert(config.get("custom_loging_method", custom_loging_method), TYPE_CALLABLE)
		custom_loging_method_verbose = type_convert(config.get("custom_loging_method_verbose", custom_loging_method_verbose), TYPE_CALLABLE)
		log_prefix = type_convert(config.get("log_prefix", log_prefix), TYPE_STRING)
		
		return true


## The primary TCP server to use
var _tcp_socket: TCPServer = TCPServer.new()

## The primary UDP server to use
var _udp_socket: PacketPeerUDP = PacketPeerUDP.new()

## The current TCP port
var _tcp_port: int = 0

## The current UDP port
var _udp_port: int = 0

## Queue of messages waiting to be send to the RelayServer once TCP connects
var _relay_tcp_queue: Array[ConstaNetHeadder]

## The broadcast relay socket
var _broadcast_relay_socket: PacketPeerUDP = PacketPeerUDP.new()

## TCP Stream connected to the RelayServer
var _relay_tcp_stream: StreamPeerTCP = StreamPeerTCP.new()

## The PacketPeerUDP to use when sending to broadcast
var _udp_broadcast_socket: PacketPeerUDP = PacketPeerUDP.new()

## Network Role
var _role_flags: int = RoleFlags.EXECUTOR

## Relay server state
var _found_relay_server: bool = true

## IP bind address
var _bind_address: String = "127.0.0.1"

## The ConstellationNode for the local node
var _local_node: ConstellationNode = ConstellationNode.create_local_node()

## All known network session
var _known_sessions: Dictionary[String, ConstellationSession]

## All Unknown sessions
var _unknown_sessions: Dictionary[String, ConstellationSession]

## Timer for node discovery
var _disco_timer: Timer = Timer.new()

## Stores all known devices by thier NodeID
var _known_nodes: Dictionary[String, ConstellationNode] = {}

## Stores all unknown nodes yet to be found on the network
var _unknown_nodes: Dictionary[String, ConstellationNode]


## Init
func _init() -> void:
	ConstellationNode._network = self
	ConstellationSession._network = self
	
	set_process(false)
	ConstellationConfig.load_config("res://ConstellaitionConfig.gd")
	
	_handler_name = "Constellation"
	settings_manager.register_setting("Session", Data.Type.NETWORKSESSION, _local_node.set_session, _local_node.get_session, [_local_node.session_changed]).set_class_filter(ConstellationSession)
	
	if not ConstellationConfig.disable_startup_details:
		Details.print_startup_detils()
	
	_local_node._set_node_ip(_bind_address)
	_local_node._set_node_name("LocalNode")
	add_child(_local_node)
	
	var cli_args: PackedStringArray = OS.get_cmdline_args()
	if cli_args.has("--ctl-node-name"):
		_local_node._set_node_name(str(cli_args[cli_args.find("--ctl-node-name") + 1]))
	
	if cli_args.has("--ctl-controler"):
		_role_flags = RoleFlags.CONTROLLER
		_local_node._set_role_flags(_role_flags)
	
	if cli_args.has("--ctl-interface"):
		_bind_address = str(cli_args[cli_args.find("--ctl-interface") + 1])
	
	if cli_args.has("--ctl-node-id"):
		_local_node._set_node_id(str(cli_args[cli_args.find("--ctl-node-id") + 1]))
	
	(func ():
		node_found.emit(_local_node)
	).call_deferred()


## Polls the socket
func _process(delta: float) -> void:
	if _udp_socket.get_available_packet_count():
		_handle_packet(_udp_socket.get_packet())
	
	_relay_tcp_stream.poll()
	if _relay_tcp_queue and _relay_tcp_stream.get_status() == StreamPeerTCP.Status.STATUS_CONNECTED:
		for message: ConstaNetHeadder in _relay_tcp_queue:
			_relay_tcp_stream.put_data(message.get_as_packet())
		
		_relay_tcp_queue.clear()


## Starts the node
func start_node() -> Error:
	if _network_state != NetworkState.OFFLINE:
		return ERR_ALREADY_EXISTS
	
	stop_node(true)
	_set_network_state(NetworkState.INITIALIZING)
	_known_nodes[get_node_id()] = _local_node
	
	_bind_network()
	if _network_state != NetworkState.BOUND:
		_log("Error staring network")
		return FAILED
	
	else:
		_log("")
		_broadcast_relay_socket.connect_to_host(NETWORK_LOOPBACK, UDP_BROADCAST_PORT)
	
	var relay_start_allowed: bool = false
	for host: String in BROADCAST_RELAY_ALLOWED_HOSTS:
		if OS.has_feature(host):
			relay_start_allowed = true
			_found_relay_server = false
			break
	
	if relay_start_allowed:
		_find_and_connect_relay()
		
	else:
		_set_network_state(NetworkState.READY)
		_begin_discovery()
	
	return OK


## Stops the node
func stop_node(p_internal_only: bool = false) -> Error:
	_log("Shutting Down")
	if not p_internal_only:
		_send_goodbye(GOODBYE_REASON_GOING_OFFLINE)
	
	_tcp_socket.stop()
	_udp_socket.close()
	_relay_tcp_stream.disconnect_from_host()
	_broadcast_relay_socket.close()
	_udp_broadcast_socket.close()
	_relay_tcp_queue.clear()
	
	for node: ConstellationNode in _known_nodes.values():
		node.close()
	
	for session: ConstellationSession in _known_sessions.values():
		session.close()
	
	_local_node._set_session_no_join(null)
	
	_known_nodes.clear()
	_known_sessions.clear()
	_unknown_nodes.clear()
	_unknown_sessions.clear()
	
	_found_relay_server = false
	_disco_timer.stop()
	
	_set_network_state(NetworkState.OFFLINE)
	_log("NetworkState: OFFLINE")
	return OK


## Sends a command to the session, using p_node_filter as the NodeFilter
func send_command(p_command: Variant, p_node_filter: NetworkSession.NodeFilter = NetworkSession.NodeFilter.MASTER) -> Error:
	if not _local_node.get_session():
		return ERR_UNAVAILABLE
	
	return _local_node.get_session().send_command(p_command, p_node_filter)


## Returns a list of all known nodes
func get_known_nodes() -> Array[NetworkNode]:
	var return_value: Array[NetworkNode]
	return_value.assign(_known_nodes.values())
	
	return return_value


## Returns all unknown NetworkNodes
func get_unknown_nodes() -> Array[NetworkNode]:
	var return_value: Array[NetworkNode]
	return_value.assign(_unknown_nodes.values())
	
	return return_value


## Returns all known NetworkSessions
func get_known_sessions() -> Array[NetworkSession]:
	var return_value: Array[NetworkSession]
	return_value.assign(_known_sessions.values())
	
	return return_value


## Returns all unknown NetworkSessions
func get_unknown_sessions() -> Array[NetworkSession]:
	var return_value: Array[NetworkSession]
	return_value.assign(_unknown_sessions.values())
	
	return return_value


## Gets the local node
func get_local_node() -> ConstellationNode:
	return _local_node


## Returns the name of the local node
func get_node_name() -> String:
	return _local_node.get_node_name()


## Gets this nodes NodeID
func get_node_id() -> String:
	return _local_node.get_node_id()


## Returns the a session from the Id, or NULL
func get_session_from_id(p_session_id: String, p_create_unknown: bool = false) -> ConstellationSession:
	if _known_sessions.has(p_session_id):
		return _known_sessions[p_session_id]
	
	elif p_create_unknown:
		if _unknown_sessions.has(p_session_id):
			return _unknown_sessions[p_session_id]
		
		var session: ConstellationSession = ConstellationSession.create_unknown_session(p_session_id)
		
		_unknown_sessions[p_session_id] = session
		
		return session
	
	return _known_sessions.get(p_session_id)


## Gets a Node from its NodeID
func get_node_from_id(p_node_id: String, p_create_unknown: bool = false) -> ConstellationNode:
	if _known_nodes.has(p_node_id):
		return _known_nodes[p_node_id]
	
	elif p_create_unknown:
		if _unknown_nodes.has(p_node_id):
			return _unknown_nodes[p_node_id]
		
		var unknown_node: ConstellationNode = ConstellationNode.create_unknown_node(p_node_id)
		
		_unknown_nodes[p_node_id] = unknown_node
		_log("Creating unknown node: ", unknown_node.get_node_id())
		
		return unknown_node
	
	return null


## Gets all the nodes as an Array of ConstellationNode
func get_node_array(p_from: ConstaNetSessionAnnounce, p_create_unknown: bool = false) -> Array[ConstellationNode]:
	var typed_array: Array[ConstellationNode]
	
	for node_id: String in p_from.nodes:
		var node: ConstellationNode = get_node_from_id(node_id, p_create_unknown)
		
		if node not in typed_array:
			typed_array.append(node)
	
	return typed_array


## Creates and joins a new session
func create_session(p_name: String) -> NetworkSession:
	if not p_name or _network_state != NetworkState.READY:
		return null
	
	var session: ConstellationSession = ConstellationSession.new()
	
	session._set_name(p_name)
	session._set_session_master(_local_node)
	session._add_node(_local_node)
	
	_known_sessions[session.get_session_id()] = session
	session.request_delete.connect(_on_session_delete_request.bind(session), CONNECT_ONE_SHOT)
	session_created.emit(session)
	
	_send_session_anouncement(session)
	return session


## Joins a pre-existing session on the network
func join_session(p_session: NetworkSession) -> bool:
	if not p_session:
		leave_session()
		return false
	
	if _local_node.get_session():
		leave_session()
	
	var message: ConstaNetSessionJoin = ConstaNetSessionJoin.new()
	
	message.origin_id = get_node_id()
	message.session_id = p_session.get_session_id()
	message.set_request(true)
	
	_local_node._set_session(p_session)
	_send_message_broadcast(message)
	
	for node: ConstellationNode in p_session.get_nodes():
		node.connect_tcp()
	
	return true


## Leaves a session 
func leave_session() -> bool:
	if not _local_node.get_session():
		return false
	
	var message: ConstaNetSessionLeave = ConstaNetSessionLeave.new()
	var session: ConstellationSession = _local_node.get_session()
	_local_node._leave_session()
	
	message.origin_id = get_node_id()
	message.session_id = session.get_session_id()
	message.set_request(true)
	
	_send_message_broadcast(message)
	
	for node: ConstellationNode in session.get_nodes():
		node.disconnect_tcp()
	
	return true


## Logs up to 8 parameters to the console
func _log(p_a=null, p_b=null, p_c=null, p_d=null, p_e=null, p_f=null, p_g=null) -> void:
	var args: Array[Variant] = [p_a, p_b, p_c, p_d, p_e, p_f, p_g].filter(func (item: Variant): return item != null)
	
	if ConstellationConfig.custom_loging_method.is_valid():
		ConstellationConfig.custom_loging_method.callv([ConstellationConfig.log_prefix] + args)
	
	else:
		print(ConstellationConfig.log_prefix, "".join(args))


## Logs up to 8 parameters to the console verbose
func _logv(p_a=null, p_b=null, p_c=null, p_d=null, p_e=null, p_f=null, p_g=null) -> void:
	var args: Array[Variant] = [p_a, p_b, p_c, p_d, p_e, p_f, p_g].filter(func (item: Variant): return item != null)
	
	if ConstellationConfig.custom_loging_method_verbose.is_valid():
		ConstellationConfig.custom_loging_method_verbose.callv([ConstellationConfig.log_prefix] + args)
	
	else:
		print_verbose(ConstellationConfig.log_prefix, "".join(args))


## Starts this node, opens network connection
func _bind_network() -> void:
	_udp_broadcast_socket.set_broadcast_enabled(true)
	_udp_broadcast_socket.set_dest_address(NETWORK_BROADCAST, UDP_BROADCAST_PORT)
	
	var tcp_error: Error = _tcp_socket.listen(0)
	var udp_error: Error = _udp_socket.bind(0)
	
	if tcp_error:
		_log("Error binding TCP: ", error_string(tcp_error))
	else:
		_tcp_port = _tcp_socket.get_local_port()
		_log("TCP bound on port: ", _tcp_port)
	
	if udp_error:
		_log("Error binding UDP: ", error_string(udp_error))
	else:
		_udp_port = _udp_socket.get_local_port()
		_log("UDP bound on port: ", _udp_port)
	
	if not tcp_error and not udp_error:
		_set_network_state(NetworkState.BOUND)
		set_process(true)
	
	else:
		_network_state_err_code = ERR_ALREADY_IN_USE
		_set_network_state(NetworkState.ERROR)


## Sends a message to UDP Broadcast
func _send_message_broadcast(p_message: ConstaNetHeadder) -> Error:
	if _network_state == NetworkState.OFFLINE:
		return ERR_UNAVAILABLE
	
	return _udp_broadcast_socket.put_packet(p_message.get_as_string().to_utf8_buffer())


## Sends a discovery message to broadcasr
func _send_discovery(p_flags: int = ConstaNetHeadder.Flags.ACKNOWLEDGMENT) -> Error:
	var packet: ConstaNetDiscovery = ConstaNetDiscovery.new()
	
	packet.origin_id = get_node_id()
	packet.node_name = get_node_name()
	packet.node_ip = _bind_address
	packet.role_flags = _role_flags
	packet.tcp_port = _tcp_port
	packet.udp_port = _udp_port
	packet.flags |= p_flags
	
	if _network_state == NetworkState.READY:
		_disco_timer.start(DISCO_TIMEOUT)
	
	return _send_message_broadcast(packet)


## Sends a session discovery message to broadcast
func _send_session_discovery(p_flags: int = ConstaNetHeadder.Flags.REQUEST) -> Error:
	var message: ConstaNetSessionDiscovery = ConstaNetSessionDiscovery.new()
	
	message.origin_id = get_node_id()
	message.flags = p_flags
	
	return _send_message_broadcast(message)


## Sends a sessions anouncement message
func _send_session_anouncement(p_session: ConstellationSession, p_flags: int = ConstaNetHeadder.Flags.ANNOUNCEMENT) -> Error:
	var message: ConstaNetSessionAnnounce = ConstaNetSessionAnnounce.new()
	
	message.origin_id = get_node_id()
	message.session_master = get_node_id()
	message.session_id = p_session.get_session_id()
	message.session_name = p_session.get_session_name()
	message.nodes = [get_node_id()]
	message.flags = p_flags
	
	return _send_message_broadcast(message)


## Sends a goodbye message
func _send_goodbye(p_reason: String, p_flags: int = ConstaNetHeadder.Flags.ANNOUNCEMENT) -> Error:
	var message: ConstaNetGoodbye = ConstaNetGoodbye.new()
	
	message.origin_id = get_node_id()
	message.flags = p_flags
	message.reason = p_reason
	
	return _send_message_broadcast(message)


## Starts the discovery stage
func _begin_discovery() -> void:
	_disco_timer.wait_time = DISCO_TIMEOUT
	
	if not _disco_timer.timeout.is_connected(_on_disco_timeout):
		_disco_timer.autostart = true
		_disco_timer.timeout.connect(_on_disco_timeout)
		add_child(_disco_timer)
	
	_send_discovery(ConstaNetHeadder.Flags.REQUEST)
	_send_session_discovery(ConstaNetHeadder.Flags.REQUEST)


## Find and connects to a RelayServer, or launches a new one
func _find_and_connect_relay() -> void:
	var relay_disco: ConstaNetDiscovery = ConstaNetDiscovery.new()
		
	relay_disco.flags = ConstaNetHeadder.Flags.REQUEST
	relay_disco.origin_id = get_node_id()
	relay_disco.target_id = RelayServer.NODE_ID
	relay_disco.node_ip = _bind_address
	relay_disco.node_name = get_node_name()
	relay_disco.tcp_port = _tcp_port
	relay_disco.udp_port = _udp_port
	
	_log("Discovering Relay Server")
	_broadcast_relay_socket.put_packet(relay_disco.get_as_string().to_utf8_buffer())
	
	if not is_node_ready():
		await ready
	
	await get_tree().create_timer(RELAY_WAIT_TIME).timeout
	
	if _found_relay_server:
		_log("Found and connected to RelayServer")
		
		_relay_tcp_stream.connect_to_host(NETWORK_LOOPBACK, RelayServer.TCP_PORT)
		_relay_tcp_queue.append(relay_disco)
		
		_set_network_state(NetworkState.READY)
		_begin_discovery()
	
	else:
		_log("Unable to find RelayServer, starting one...")
		OS.create_instance(["--main-loop", "RelayServer", "--headless"])
		
		await get_tree().create_timer(RELAY_BOOT_WAIT_TIME).timeout
		
		var retries: int = 0
		while retries < RELAY_MAX_RETRIES and not _found_relay_server:
			_broadcast_relay_socket.put_packet(relay_disco.get_as_string().to_utf8_buffer())
			await get_tree().create_timer(RELAY_BOOT_WAIT_TIME).timeout
			retries += 1
		
		if _found_relay_server:
			_log("Started RelayServer")
			
			_relay_tcp_queue.append(relay_disco)
			_begin_discovery()
			_set_network_state(NetworkState.READY)
		
		else:
			_log("Unable to contact RelayServer after retries: ", retries)
			_network_state_err_code = ERR_CANT_CONNECT
			_set_network_state(NetworkState.ERROR)


## Handles a packet as a PackedByteArray
func _handle_packet(p_packet: PackedByteArray) -> void:
	var message: ConstaNetHeadder = ConstaNetHeadder.phrase_string(p_packet.get_string_from_utf8())
		
	if message.origin_id == RelayServer.NODE_ID:
		_found_relay_server = true
		return
	
	if message.is_valid() and message.origin_id != _local_node.get_node_id():
		_handle_message(message)


## Handles an incomming message, 
func _handle_message(p_message: ConstaNetHeadder) -> void:
	if p_message.target_id and p_message.target_id != get_node_id():
		return
	
	if p_message.type == MessageType.DISCOVERY and p_message.flags & ConstaNetHeadder.Flags.REQUEST:
		_send_discovery(ConstaNetHeadder.Flags.ACKNOWLEDGMENT)
	
	match p_message.type:
		MessageType.DISCOVERY:
			_handle_discovery_message(p_message)
		
		MessageType.SESSION_DISCOVERY:
			for p_session: ConstellationSession in _known_sessions.values():
				if p_session.get_session_master() == _local_node:
					_send_session_anouncement(p_session, ConstaNetHeadder.Flags.ACKNOWLEDGMENT)
		
		MessageType.SESSION_ANNOUNCE:
			_handle_session_announce_message(p_message)
		
		MessageType.SESSION_SET_PRIORITY:
			var node: ConstellationNode = get_node_from_id(p_message.node_id)
			var session: ConstellationSession = get_session_from_id(p_message.session_id)
			
			if node and session:
				session._set_priority_order(node, p_message.position)
		
		MessageType.SESSION_SET_MASTER:
			var node: ConstellationNode = get_node_from_id(p_message.node_id)
			var session: ConstellationSession = get_session_from_id(p_message.session_id)
			
			if node and session:
				session._set_session_master(node)
	
	if p_message.target_id == get_node_id():
		_local_node.handle_message(p_message)
	
	elif not p_message.target_id and p_message.origin_id in _known_nodes:
		_known_nodes[p_message.origin_id].handle_message(p_message)


## Handles a discovery message
func _handle_discovery_message(p_discovery: ConstaNetDiscovery) -> void:
	if p_discovery.origin_id not in _known_nodes:
		var node: ConstellationNode
		if p_discovery.origin_id in _unknown_nodes:
			node = _unknown_nodes[p_discovery.origin_id]
			node._mark_as_unknown(false)
			node.update_from_discovery(p_discovery)
			
			_unknown_nodes.erase(p_discovery.origin_id)
			_log("Using unknown node: ", node.get_node_id())
			
		
		else:
			node = ConstellationNode.create_from_discovery(p_discovery)
			
		_known_nodes[p_discovery.origin_id] = node
		add_child(node)
		node_found.emit(node)


## Handles a session announce message
func _handle_session_announce_message(p_message: ConstaNetSessionAnnounce) -> void:
	if _known_sessions.has(p_message.session_id):
		_known_sessions[p_message.session_id].update_with(p_message)
	
	else:
		var session: ConstellationSession
		
		if _unknown_sessions.has(p_message.session_id):
			session = _unknown_sessions[p_message.session_id]
			session._mark_as_unknown(false)
			session.update_with(p_message)
			
			_unknown_sessions.erase(p_message.session_id)
			_log("Using unknown session: ", session.get_session_id())
		
		else:
			session = ConstellationSession.create_from_session_announce(p_message)
		
		_known_sessions[session.get_session_id()] = session
		session.request_delete.connect(_on_session_delete_request.bind(session), CONNECT_ONE_SHOT)
		
		session_created.emit(session)


## Sets the network state
func _set_network_state(p_network_state: NetworkState) -> bool:
	if p_network_state == _network_state:
		return false
	
	_network_state = p_network_state
	network_state_changed.emit(_network_state, _network_state_err_code if _network_state == NetworkState.ERROR else OK)
	
	return true


## Called when the discovery timer times out
func _on_disco_timeout() -> void:
	_send_discovery()


## Called when the sessions is to be deleted after all nodes disconnect
func _on_session_delete_request(p_session: ConstellationSession) -> void:
	_known_sessions.erase(p_session.get_session_id())

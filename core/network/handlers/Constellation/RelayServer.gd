# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name RelayServer extends MainLoop
## Relay server for the Constellation Network Engine


## Node of the RelayServer
const NODE_ID: String = "RelayServer"

## UDP bind port
const UDP_BROADCAST_PORT: int = 3823

## TCP bind port
const TCP_PORT: int = 3824

## Network loopback address
const NETWORK_LOOPBACK: String = "127.0.0.1"

## MessageType for ConstaNetDiscovery messages
const DISCOVERY_MESSAGE_TYPE: int = 1


## The UDP server
var _udp_peer: PacketPeerUDP = PacketPeerUDP.new()

## The TCP server
var _tcp_server: TCPServer = TCPServer.new()

## Dictonary for all nodes
var _nodes: Dictionary[String, Dictionary]

## RefMap for NodeID: StreamPeerTCP
var _node_streams: RefMap = RefMap.new()

## Connected TCP Peers
var _peers: Array[StreamPeerTCP]

## Debug brick state
var _is_bricked: bool = false


## Init 
func _initialize():
	print("RelayServer: Initializing")
	OS.set_thread_name("RelayServer")
	
	_is_bricked = "--bricked" in OS.get_cmdline_args()
	
	var tcp_error: Error = _tcp_server.listen(TCP_PORT, NETWORK_LOOPBACK)
	if tcp_error == ERR_ALREADY_IN_USE:
		print("RelayServer: Another instance of RelayServer is already running, exiting...")
		OS.kill(OS.get_process_id())
	
	var udp_error: Error = _udp_peer.bind(UDP_BROADCAST_PORT)
	if udp_error:
		print("RelayServer: UDP bind error: ", error_string(udp_error))
		return
	
	print("RelayServer: Ready")
	if _is_bricked:
		print("RelayServer: BRICKED")


## Process
func _process(delta):
	if _is_bricked:
		return
	
	while _udp_peer.get_available_packet_count():
		handle_incomming_packet(_udp_peer.get_packet())
	
	if _tcp_server.is_connection_available():
		var peer: StreamPeerTCP = _tcp_server.take_connection()
		_peers.append(peer)
	
	for peer: StreamPeerTCP in _peers.duplicate():
		peer.poll()
		
		match peer.get_status():
			StreamPeerTCP.Status.STATUS_CONNECTED:
				if peer.get_available_bytes():
					var data: Array = peer.get_data(peer.get_available_bytes())
					
					if not handle_incomming_packet(data[1], peer):
						print("RelayServer: TCP Stream did not send a valid ConstaNet packet, disconnecting...")
						peer.disconnect_from_host()
						_peers.erase(peer)
			
			StreamPeerTCP.Status.STATUS_NONE, StreamPeerTCP.Status.STATUS_ERROR:
				peer.disconnect_from_host()
				_peers.erase(peer)
				
				if _node_streams.has_right(peer):
					var node_id: String = _node_streams.right(peer)
					print("RelayServer: Lost Connection From: ", _nodes[node_id].disco.node_name)
					
					_nodes.erase(node_id)
					_node_streams.erase_right(peer)
					
				else:
					print("RelayServer: TCP Lost Connection From: ", peer.get_connected_port())

## Called before exit
func _finalize():
	print("RelayServer: Shutting Down")
	
	for peer: StreamPeerTCP in _peers:
		peer.disconnect_from_host()


## Handles the incomming packet
func handle_incomming_packet(p_packet: PackedByteArray, p_stream: StreamPeerTCP = null) -> bool:
	var message: ConstaNetHeadder = ConstaNetHeadder.phrase_string(p_packet.get_string_from_utf8())
	
	var as_string: String = p_packet.get_string_from_utf8()
	if not as_string:
		
		print("Got: ", p_packet)
		print("From: ", _udp_peer.get_packet_port())
		print("From: ", _udp_peer.get_packet_ip())
		print()
	
	if message and message.type == ConstaNetHeadder.Type.DISCOVERY and message.is_valid() and message.target_id == NODE_ID and message.flags == ConstaNetHeadder.Flags.REQUEST:
		if !message.origin_id in _nodes:
			_nodes[message.origin_id] = {}
			print("RelayServer: New connection from: ", message.node_name)
		
		_nodes[message.origin_id].disco = message
		
		if p_stream:
			_nodes[message.origin_id].peer = p_stream
			_node_streams.map(message.origin_id, p_stream)
		
		else:
			send_reply(message)
		
		return true
	
	elif message:
		if not message.is_valid():
			return false
		
		message.flags |= ConstaNetHeadder.Flags.RETRANSMISSION
		for node: Dictionary in _nodes.values():
			_udp_peer.set_dest_address(node.disco.node_ip, node.disco.udp_port)
			_udp_peer.put_packet(message.get_as_packet())
		
		return false
	
	else:
		return false


## Sends a reply to an incomming ConstaNetDiscovery message
func send_reply(p_message: ConstaNetDiscovery) -> bool:
	if p_message.origin_id not in _nodes:
		return false
	
	var reply: ConstaNetDiscovery = ConstaNetDiscovery.new()
	
	reply.flags = ConstaNetHeadder.Flags.ACKNOWLEDGMENT
	reply.origin_id = NODE_ID
	reply.target_id = p_message.origin_id
	reply.node_name = NODE_ID
	reply.node_ip = NETWORK_LOOPBACK
	
	_udp_peer.set_dest_address(p_message.node_ip, p_message.udp_port)
	_udp_peer.put_packet(reply.get_as_string().to_utf8_buffer())
	return true

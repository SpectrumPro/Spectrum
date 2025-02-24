# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UDPSocketClient extends Node
## UDP Socket client, used by the client controller to handle high frequency data


## Emitted when a packet is recieved
signal packet_recieved(packet: PackedByteArray)

## The UDP packet peer used to connect to the server
var _connection := PacketPeerUDP.new()


## Connect to a host server
func connect_to_host(ip: String, port: int) -> Error:
	var err_code: int = _connection.connect_to_host(ip, port)
	
	# Send a message back to the server, this will tell the server that we are listning and to start sending data. 
	# This message can say anything, as the contence is not read
	_connection.put_var("Hello, UDP!")
	
	return err_code

## Close the connection
func close() -> void:
	_connection.close()


func _process(delta):
	if _connection.get_available_packet_count():
		var data: Dictionary = {}
		for packed_number: int in range(0, _connection.get_available_packet_count()):
			var packet: Variant = _connection.get_var()
			if packet is Dictionary:
				data.merge(packet, true)
		
		packet_recieved.emit(data)

# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name ArtNetOutput extends DataOutputPlugin

var ip_address: String = "127.0.0.1" ## IP address of node to connect to
var port: int = 6454 ## Art-Net port number
var universe_number: int = 0 ## Art-Net universe number

var _udp_peer = PacketPeerUDP.new() ## PacketPeerUDP responsible for sending Art-Net packets

## Called when this object is first created
func _component_ready():
	# Sets name, description, and authors list of this plugin
	self.plugin_name = "Art-Net Output"
	self.plugin_authors = ["Liam Sherwin"]
	self.plugin_description = "Outputs dmx data over Art-Net"
	
	self_class_name = "ArtNetOutput"


## Called when this output is started
func start():
	pass


## Called when this output is stoped
func stop():
	pass


## Called when this output it told to output
func output() -> void:
	pass


## Called when this output is requested to serialize its config
func _on_serialize_request():
	
	return {
		"ip_address": ip_address,
		"port": port,
		"universe_number": universe_number
	}


## Called when this object is requested to be deleted
func _on_delete_request():
	pass

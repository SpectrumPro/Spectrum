# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name ConstaNetDiscovery extends ConstaNetHeadder
## ConstaNET Discovery packet


## The name of the origin node
var node_name: String = "UnNamedNode"

## The IP address of the origin node
var node_ip: String = ""

## The NetworkRole of this node
var role_flags: int = RoleFlags.EXECUTOR

## The TCP port used by this node
var tcp_port: int = 0

## The UDP port used by this node
var udp_port: int = 0


## Init
func _init() -> void:
	type = Type.DISCOVERY


## Gets this ConstaNetDiscovery as a Dictionary
func _get_as_dict() -> Dictionary[String, Variant]:
	return {
		"node_name": node_name,
		"node_ip": node_ip,
		"role_flags": role_flags,
		"tcp_port": tcp_port,
		"udp_port": udp_port
	}


## Gets this ConstaNetDiscovery as a PackedByteArray
func _get_as_packet() -> PackedByteArray:
	var result: PackedByteArray = PackedByteArray()
	var name_buffer: PackedByteArray = node_name.to_ascii_buffer()
	
	if name_buffer.size() > (1 << 16):
		name_buffer.resize((1 << 16))
	
	result.append(name_buffer.size())	## Name length
	result.append_array(name_buffer)	## Name string
	
	result.append_array(ip_to_bytes(node_ip))	## Ip address
	result.append_array(ba(role_flags, 2))		## Role flags
	
	result.append_array(ba(tcp_port, 2))		## TCP port
	result.append_array(ba(udp_port, 2))		## UDP port
	
	return result


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	node_name = type_convert(p_dict.get("node_name", ""), TYPE_STRING)
	node_ip = type_convert(p_dict.get("node_ip", ""), TYPE_STRING)
	role_flags = type_convert(p_dict.get("role_flags", 0), TYPE_INT)
	tcp_port = type_convert(p_dict.get("tcp_port", 0), TYPE_INT)
	udp_port = type_convert(p_dict.get("udp_port", 0), TYPE_INT)


## Phrases a PackedByteArray
func _phrase_packet(p_packet: PackedByteArray) -> void:
	if p_packet.size() < 1:
		return
	
	var offset: int = 0
	var name_length: int = p_packet.decode_u8(offset)
	offset += 1
	
	if p_packet.size() < offset + name_length + 10:
		return
	
	node_name = p_packet.slice(offset, offset + name_length).get_string_from_ascii()
	offset += name_length
	
	node_ip = bytes_to_ip(p_packet.slice(offset, offset + 4))
	offset += 4
	
	role_flags = ba_to_int(p_packet, offset, 2)
	offset += 2
	
	tcp_port = ba_to_int(p_packet, offset, 2)
	offset += 2
	
	udp_port = ba_to_int(p_packet, offset, 2)
	offset += 2


## Checks if this ConstaNetDiscovery is valid
func _is_valid() -> bool:
	if node_name and node_ip and tcp_port and udp_port:
		return true
	
	return false


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


## Phrases a Dictionary
func _phrase_dict(p_dict: Dictionary) -> void:
	node_name = type_convert(p_dict.get("node_name", ""), TYPE_STRING)
	node_ip = type_convert(p_dict.get("node_ip", ""), TYPE_STRING)
	role_flags = type_convert(p_dict.get("role_flags", 0), TYPE_INT)
	tcp_port = type_convert(p_dict.get("tcp_port", 0), TYPE_INT)
	udp_port = type_convert(p_dict.get("udp_port", 0), TYPE_INT)


## Checks if this ConstaNetDiscovery is valid
func _is_valid() -> bool:
	if node_name and node_ip and tcp_port and udp_port:
		return true
	
	return false

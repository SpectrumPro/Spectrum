# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name IPAddr extends RefCounted
## Class to represent an IPAddress


## The type of this IPAddr
var _type: IP.Type = IP.Type.TYPE_ANY

## The IP Address of this IPAddr
var _address: String = ""

## The interface name of this IPAddr
var _interface: String = ""


## init
func _init(p_type: IP.Type = IP.Type.TYPE_ANY, p_address: String = "", p_interface: String = "") -> void:
	_type = p_type
	_address = p_address
	_interface = p_interface


## Checks is this IPAddr is valid
func is_valid() -> bool:
	if not _address.is_valid_ip_address():
		return false
	
	if not _address:
		return false
	
	if _type == IP.Type.TYPE_NONE:
		return false
	
	return true


## Sets the type of this IPAddr
func set_type(p_type: IP.Type) -> bool:
	if p_type == _type:
		return false
	
	_type = p_type
	return true


## Sets the IP address of this IPAddr, also sets the address type
func set_address(p_address: String) -> bool:
	if p_address == _address:
		return false
	
	_address = p_address
	
	if not _address:
		set_type(IP.Type.TYPE_NONE)
	
	elif _address.contains(":"):
		set_type(IP.Type.TYPE_IPV6)
	
	else:
		set_type(IP.Type.TYPE_IPV4)
	
	return true


## Sets the interface name of this IPAddr
func set_interface(p_interface: String) -> bool:
	if p_interface == _interface:
		return false
	
	_interface = p_interface
	return true


## Gets the type of this IPAddr
func get_type() -> IP.Type:
	return _type


## Gets the IP address of this IPAddr
func get_address() -> String:
	return _address


## Gets the interface name of this IPAddr
func get_interface() -> String:
	return _interface


## Convers this IPAddr to a string
func _to_string() -> String:
	return _interface + ":" + _address

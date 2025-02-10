# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name ArtNetOutput extends DMXOutput


## IP address of node to connect to
var _ip_address: String = "192.168.1.73"

## Art-Net port number
var _port: int = 6454

## Art-Net universe number
var _universe_number: int = 0


## Called when this object is first created
func _component_ready():
	_set_self_class("ArtNetOutput")


## Loads this component from a dictonary
func _on_load_request(serialized_data: Dictionary) -> void:
	_ip_address = str(serialized_data.get("ip_address", _ip_address))
	_port = int(serialized_data.get("port", _port))
	_universe_number = int(serialized_data.get("universe_number", _universe_number))

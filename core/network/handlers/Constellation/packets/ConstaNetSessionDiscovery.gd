# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name ConstaNetSessionDiscovery extends ConstaNetHeadder
## ConstaNET Session Anounce message


## Init
func _init() -> void:
	type = Type.SESSION_DISCOVERY


## Gets this ConstaNetSessionDiscovery as a Dictonary
func _get_as_dict() -> Dictionary[String, Variant]:
	return {}


## Gets this ConstaNetSessionDiscovery as a PackedByteArray
func _get_as_packet() -> PackedByteArray:
	return []


## Checks if this ConstaNetSessionDiscovery is valid
func _is_valid() -> bool:
	return true

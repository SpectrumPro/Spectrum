
# Copyright (c) 2025 Liam Sherwin, All rights reserved.
# This file is part of the Constellation Network Engine, licensed under the GPL v3.

class_name ConstaNetSessionDiscovery extends ConstaNetHeadder
## ConstaNET Session Anounce message


## Init
func _init() -> void:
	type = Type.SESSION_DISCOVERY


## Checks if this ConstaNetSessionDiscovery is valid
func _is_valid() -> bool:
	return true

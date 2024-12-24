# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UIProgrammer extends UIPanel
## Programmer to adust the settings and paramiters of units


func _ready() -> void:
	set_move_resize_handle($VBoxContainer/PanelContainer/HBoxContainer/EditControls/HBoxContainer/MoveResize)

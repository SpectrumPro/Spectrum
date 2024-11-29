# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name VirtualFixtures extends UIPanel
## Layout view for showing vixtures


func _ready() -> void:
	set_move_resize_handle($TitleBar/HBoxContainer/EditControls/HBoxContainer/MoveResize)

# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name PanelPickerItem extends Button
## Button for the PanelPicker


## Sets the title of this item
func set_title(title: String) -> void:
	$PanelContainer/HBoxContainer/PanelContainer2/VBoxContainer/Title.text = title


## Sets the info
func set_info(info: String) -> void:
	$PanelContainer/HBoxContainer/PanelContainer2/VBoxContainer/Info.text = info


## Sets the icon
func set_icon(icon: Texture2D) -> void:
	$PanelContainer/HBoxContainer/PanelContainer/TextureRect.texture = icon

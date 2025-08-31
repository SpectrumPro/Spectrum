# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UICoreStatusBar extends PanelContainer
## Core UI script for the main status bar


## The UICoreResolveButtons node
@export var resolve_button_container: UICoreResolveButtons

@export_group("Nodes")

## The VersionLabel
@export var _version_label: Label

## The QuickAccessContainer
@export var _quick_access_container: HBoxContainer


## Config for quick access buttons
var _quick_access_config: Array = [
	#{
		#"panel": Interface.panels.Programmer,
		#"icon": load("res://assets/icons/Programmer.svg"),
		#"size": Vector2.ZERO,
	#},
	#{
		#"panel": Interface.panels.Fixtures,
		#"icon": load("res://assets/icons/Fixture.svg"),
		#"size": Vector2(800, 500)
	#},
	#{
		#"panel": Interface.panels.Functions,
		#"icon": load("res://assets/icons/Functions.svg"),
		#"size": Vector2(800, 500)
	#},
	#{
		#"panel": Interface.panels.Settings,
		#"icon": load("res://assets/icons/Settings.svg"),
		#"size": Vector2.ZERO
	#},
	#{
		#"panel": Interface.panels.SaveLoad,
		#"icon": load("res://assets/icons/Storage.svg"),
		#"size": Vector2(1200, 800)
	#},
]


func _ready() -> void:
	_version_label.text = Details.version
	_reload_quick_access()


## Reloads the list of quick access buttons
func _reload_quick_access() -> void:
	for old_button: Button in _quick_access_container.get_children():
		old_button.queue_free()
	
	for config: Dictionary in _quick_access_config:
		var new_button: Button = Button.new()
		var new_panel: UIPanel = config.panel.instantiate()
		
		new_panel.hide()
		get_tree().process_frame.connect(func ():
			config.size = config.size if config.size != Vector2.ZERO else new_panel.get_combined_minimum_size()
			new_panel.set_anchors_preset(Control.PRESET_CENTER)
			new_panel.size = config.size
			new_panel.position = (size / 2) - (config.size / 2)
		, CONNECT_ONE_SHOT)
		
		new_button.icon = config.icon
		new_button.flat = false
		new_button.toggle_mode = true
		new_button.toggled.connect(func (toggled_on: bool):
			if toggled_on:
				Interface.show_custom_popup(new_panel)
			else:
				Interface.hide_custom_popup(new_panel)
		)
		new_panel.close_request.connect(new_button.set_pressed_no_signal.bind(false))
		
		_quick_access_container.add_child(new_button)
		Interface.add_custom_popup(new_panel)


## Called when the quick action button is toggled
func _on_action_button_toggled(toggled_on: bool) -> void:
	Interface.set_visible_and_fade(resolve_button_container, toggled_on)

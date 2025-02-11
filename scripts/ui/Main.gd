# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIPrimaryLayout extends UIPanel
## Primary UI layout


## The Color Rect that flashes differnt colors during disconnects and other things
@export var _flash_background: ColorRect = null

## The control that contains all the tabs
@export var _tab_container: CustomTabContainer = null

## The container for quick access buttons
@export var _quick_access_container: HBoxContainer = null


## The number of warning bg flashes
var _warning_flashes: int = 3

## How long each flash it
var _flash_duration: float = 0.5

## Color of the disconnect warning flash
var _disconnect_warning_color: Color = Color(1, 0, 0, 0.5)

var _quick_access_config: Array = [
	{
		"panel": Interface.panels.Programmer,
		"icon": load("res://assets/icons/Programmer.svg"),
		"size": Vector2.ZERO
	},
	{
		"panel": Interface.panels.Fixtures,
		"icon": load("res://assets/icons/Fixture.svg"),
		"size": Vector2(800, 500)
	},
	{
		"panel": Interface.panels.Functions,
		"icon": load("res://assets/icons/Functions.svg"),
		"size": Vector2.ZERO
	},
	{
		"panel": Interface.panels.Settings,
		"icon": load("res://assets/icons/Settings.svg"),
		"size": Vector2.ZERO
	},
	{
		"panel": Interface.panels.SaveLoad,
		"icon": load("res://assets/icons/Storage.svg"),
		"size": Vector2(1200, 800)
	},
]


func _ready() -> void:
	Client.connection_closed.connect(_on_connection_closed)
	_reload_quick_access()


## Called when there is an unexpected disconnect from the server
func _on_connection_closed() -> void:
	if not Client.is_expecting_disconnect():
		var animation: Tween = create_tween()
		for i in range(0, _warning_flashes):
			animation.tween_method(_flash_background.set_color, Color.TRANSPARENT, _disconnect_warning_color, _flash_duration)
			animation.tween_method(_flash_background.set_color, _disconnect_warning_color, Color.TRANSPARENT, _flash_duration)


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
		
	


## Saves all the tabs
func _save() -> Dictionary:
	var saved_data: Dictionary = {
		"tabs": [],
		"current": _tab_container.get_current_tab()
	}
	
	for panel: UIPanel in _tab_container.get_children():
		var script_name: String =  panel.get_script().resource_path.get_file()
		
		saved_data.tabs.append({
			"type": script_name.substr(0, script_name.rfind(".")),
			"settings": panel.save(),
			"name": _tab_container.get_tab_title(panel.get_index())
		})
	
	return saved_data


## Loads all the tabs
func _load(saved_data: Dictionary) -> void:
	for saved_panel: Dictionary in saved_data.get("tabs", {}):
		if saved_panel.get("type", "") in Interface.panels:
			var new_panel: UIPanel = Interface.panels[saved_panel.type].instantiate()
			
			_tab_container.add_tab(str(saved_panel.get("name", "")), new_panel)
			new_panel.load(saved_panel.get("settings", {}))
	
	_tab_container.change_tab(saved_data.get("current", 0))


## Called when the new tab button is pressed
func _on_new_tab_pressed() -> void:
	_tab_container.add_tab("New Desk", Interface.panels.Desk.instantiate())


## Called when the close tab button is pressed
func _on_close_tab_pressed() -> void:
	Interface.show_delete_confirmation().confirmed.connect(func ():
		_tab_container.remove_tab(_tab_container.get_current_tab())
	)


func _on_edit_tab_pressed() -> void:
	var current_name: String = _tab_container.get_tab_title(_tab_container.get_current_tab())
	Interface.show_name_dialog("Rename Tab", current_name).confirmed.connect(func (p_name: String):
		_tab_container.set_tab_title(_tab_container.get_current_tab(), p_name)
	)

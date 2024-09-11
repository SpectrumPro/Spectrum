# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## Handles the ui components on the main window


## The TabBar node
@onready var _tab_bar: TabBar = $VBoxContainer/PanelContainer/HBoxContainer/TabBar

## The control node that holds the tabs
@onready var _tab_container: Control = $VBoxContainer/Tabs

## The rename input box
@onready var _rename_input_box: LineEdit = $RenameBox/VBoxContainer/LineEdit


## The number of warning bg flashes
var _warning_flashes: int = 3

## How long each flash it
var _flash_duration: float = 0.5

## The colors of the warning flashes
var _warning_from_color: Color = Color(1, 0, 0, 0)
var _warning_to_color: Color = Color(1, 0, 0, 0.5)


func _ready() -> void:
	MainSocketClient.connection_closed.connect(_on_connection_closed)
	
	Interface.kiosk_mode_changed.connect(_on_kiosk_mode_changed)


func _on_connection_closed() -> void:
	if not Core.is_expecting_disconnect:
		var animation: Tween = create_tween()
		for i in range(0, _warning_flashes):
			animation.tween_method($WarningBG.set_color, _warning_from_color, _warning_to_color, _flash_duration)
			animation.tween_method($WarningBG.set_color, _warning_to_color, _warning_from_color, _flash_duration)
		
		$VBoxContainer/PanelContainer/HBoxContainer/QuickAccessButtons/HBoxContainer/Settings.add_theme_color_override("icon_normal_color", Color.RED)
		$VBoxContainer/PanelContainer/HBoxContainer/QuickAccessButtons/HBoxContainer/Settings.add_theme_color_override("icon_hover_color", Color.RED)
		$VBoxContainer/PanelContainer/HBoxContainer/QuickAccessButtons/HBoxContainer/Settings.add_theme_color_override("icon_focus_color", Color.RED)


func _on_kiosk_mode_changed(kiosk_mode: bool) -> void:
	$VBoxContainer/PanelContainer/HBoxContainer/TabAndWindowButtons.visible = not kiosk_mode
	$VBoxContainer/PanelContainer/HBoxContainer/FileButtons.visible = not kiosk_mode


## Saves all the panels shown in the ui
func save() -> Array:
	var save_data: Array = []
	
	for panel: Control in _tab_container.get_children():
		if panel.get("save") is Callable:
			var script_name: String =  panel.get_script().resource_path.get_file()
			
			save_data.append({
				"type": script_name.substr(0, script_name.rfind(".")),
				"settings": panel.save(),
				"name": _tab_bar.get_tab_title(panel.get_index())
			})
	
	return save_data


func load(saved_data: Array) -> void:
	for saved_panel: Dictionary in saved_data:
		if saved_panel.get("type", "") in Interface.panels:
			var new_panel: Control = Interface.panels[saved_panel.type].instantiate()
			
			_tab_container.add_tab(new_panel, false)
			_tab_bar.add_tab(saved_panel.get("name", new_panel.name))
			
			if new_panel.get("load") is Callable:
				new_panel.load(saved_panel.get("settings", {}))
	
	_tab_container.change_tab(_tab_bar.current_tab)


func _on_file_toggled(toggled_on: bool) -> void:
	$SaveLoad.visible = toggled_on
	$SaveLoad.move_to_front()


func _on_programmer_toggled(toggled_on: bool) -> void:
	$Programmer.visible = toggled_on
	$Programmer.move_to_front()


func _on_scenes_toggled(toggled_on: bool) -> void:
	$Playbacks.visible = toggled_on
	$Playbacks.move_to_front()


func _on_fixtures_toggled(toggled_on: bool) -> void:
	$Fixtures.visible = toggled_on
	$Fixtures.move_to_front()


func _on_functions_toggled(toggled_on: bool) -> void:
	$Functions.visible = toggled_on
	$Functions.move_to_front()



func _on_settings_toggled(toggled_on: bool) -> void:
	$VBoxContainer/PanelContainer/HBoxContainer/QuickAccessButtons/HBoxContainer/Settings.remove_theme_color_override("icon_normal_color")
	$VBoxContainer/PanelContainer/HBoxContainer/QuickAccessButtons/HBoxContainer/Settings.remove_theme_color_override("icon_hover_color")
	$VBoxContainer/PanelContainer/HBoxContainer/QuickAccessButtons/HBoxContainer/Settings.remove_theme_color_override("icon_focus_color")
	
	
	$Settings.visible = toggled_on
	$Settings.move_to_front()


func _on_new_tab_pressed() -> void:
	#var new_panel: Desk = desk_panel.instantiate()
	var new_panel: Desk = Interface.panels.Desk.instantiate()
	#var new_panel: Desk = preload("res://panels/Desk/Desk.tscn").instantiate()
	
	print(Interface.panels)
	
	_tab_bar.add_tab("Desk")
	_tab_bar.current_tab = _tab_bar.tab_count - 1
	
	_tab_container.add_child(new_panel)
	_tab_container.change_tab(_tab_bar.current_tab)


func _on_close_tab_pressed() -> void:
	$ConfirmationBox.show()
	$ConfirmationBox.move_to_front()


func _on_close_confirmation_pressed() -> void:
	$ConfirmationBox.hide()
	var current_tab_idx: int = _tab_bar.current_tab
	
	_tab_bar.remove_tab(current_tab_idx)
	_tab_container.remove_tab(current_tab_idx)


func _on_close_confirmation_cancel_pressed() -> void:
	$ConfirmationBox.hide()



func _on_edit_tab_pressed() -> void:
	_rename_input_box.text = _tab_bar.get_tab_title(_tab_bar.current_tab)
	$RenameBox.show()
	$RenameBox.move_to_front()



func _on_rename_box_cancel_pressed() -> void:
	$RenameBox.hide()


func _on_rename_box_rename_pressed() -> void:
	if _rename_input_box.text:
		_tab_bar.set_tab_title(_tab_bar.current_tab, _rename_input_box.text)
		$RenameBox.hide()

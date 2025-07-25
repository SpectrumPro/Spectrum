# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UICorePrimarySideBar extends Control
## The primary side bar for UICore


## Maximun number of visable tabs
@export var max_visable_tabs: int = 20

## Minuimun Height in px for tab buttons
@export var button_min_height: int = 40

## Font size for tab buttons
@export var button_font_size: int = 11

## Separation in px for tab buttons
@export var button_separation: int = 4

## The modulate color for tab buttons
@export var tab_button_modulate: Color = Color.WHITE

## The modulate color for disabled tab buttons
@export var disabled_tab_button_modulate: Color = Color.WHITE

## The name for the default tab
@export var default_tab_name: String = "TAB#"


@export_group("Nodes")

## The BoxContainer for tab Buttons
@export var _tab_button_container: BoxContainer

## The ScrollContainer that contains the _tab_button_container
@export var _tab_button_scroll: ScrollContainer

## The container for tab Control nodes
@export var _tab_control_container: Control

## The Menu Button
@export var _menu_button: Button

## The Edit Button
@export var _edit_button: Button

## The PanelTypeOption menu
@export var _panel_type_option: PanelContainer


## All tab Buttons stored by tab number
var _tab_buttons: Array[Button]

## RefMap for TabID: UIPanel
var _tab_controls: RefMap = RefMap.new()

## The current tab number
var _current_tab: int = 0

## The current visable tabs control node
var _current_visable_panel: UIPanel

## The Button Group to asign all tab buttons to
var _button_group: ButtonGroup = ButtonGroup.new()


func _ready() -> void:
	for i in range(max_visable_tabs + 1):
		var new_button: Button = _create_tab_button("", i)
		
		_tab_buttons.append(new_button)
		_tab_button_container.add_child(new_button)
	
	var new_desk: UIDesk = Interface.panels.Desk.instantiate()
	
	new_desk.set_menu_bar_visable(false)
	_tab_controls.map(_current_tab, new_desk)
	_current_visable_panel = new_desk
	
	_tab_control_container.add_child(new_desk)
	_tab_buttons[_current_tab].self_modulate = tab_button_modulate
	_tab_buttons[_current_tab].set_pressed_no_signal(true)
	_tab_buttons[_current_tab].get_child(0).set_text(default_tab_name.replace("#", "0"))
	
	_tab_button_container.add_theme_constant_override("separation", button_separation)


## Changes to a tab
func change_to_tab(p_tab_id: int) -> bool:
	if p_tab_id == _current_tab or p_tab_id > len(_tab_buttons):
		return false
	
	if _tab_controls.has_left(p_tab_id):
		if _current_visable_panel:
			_current_visable_panel.hide()
		
		_panel_type_option.hide()
		
		_current_visable_panel = _tab_controls.left(p_tab_id)
		_current_visable_panel.show()
		
		_edit_button.disabled = false
		_edit_button.set_pressed_no_signal(_current_visable_panel.get_edit_mode())
		
		_tab_buttons[p_tab_id].set_pressed_no_signal(true)
	
	else:
		if _current_visable_panel:
			_current_visable_panel.hide()
		
		_panel_type_option.show()
		
		_current_visable_panel = null
		_edit_button.disabled = true
		
		_tab_buttons[p_tab_id].set_pressed_no_signal(true)
	
	_current_tab = p_tab_id
	return true


## Updates the visable buttons to match the current size
func match_visable_to_size() -> void:
	var container_height: int = _tab_button_scroll.size.y
	
	for i: int in range(len(_tab_buttons)):
		var button: Button = _tab_buttons[i]
		
		button.visible = (i + 1) * (button_min_height + button_separation) <= container_height


## Adds a desk on the current tab
func create_desk() -> bool:
	if _tab_controls.has_left(_current_tab):
		return false
	
	var new_desk: UIDesk = Interface.panels.Desk.instantiate()
	new_desk.set_menu_bar_visable(false)
	
	_tab_controls.map(_current_tab, new_desk)
	_tab_control_container.add_child(new_desk)
	_current_visable_panel = new_desk
	
	_tab_buttons[_current_tab].get_child(0).set_text(default_tab_name.replace("#", str(_current_tab)))
	_tab_buttons[_current_tab].self_modulate = tab_button_modulate
	_panel_type_option.hide()
	
	return true


## Sets the edit mode state on the current selected tab
func set_tab_edit_mode(p_edit_mode: bool) -> bool:
	if not _current_visable_panel:
		return false
	
	_current_visable_panel.set_edit_mode(p_edit_mode)
	return true


## Creates a tab button
func _create_tab_button(p_text: String, p_index: int) -> Button:
	var button: Button = Button.new()
	var label: Label = Label.new()
	
	label.text = p_text
	label.add_theme_font_size_override("font_size", button_font_size)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	button.add_child(label)
	button.custom_minimum_size = Vector2(0, button_min_height)
	button.self_modulate = disabled_tab_button_modulate
	button.toggle_mode = true
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.button_group = _button_group
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	
	button.pressed.connect(change_to_tab.bind(p_index))
	
	return button

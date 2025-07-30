# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.


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

## Size in PX for the menu bar overlay
@export var menu_bar_default_size: int = 900


@export_group("Nodes")

## The BoxContainer for tab Buttons
@export var _tab_button_container: BoxContainer

## The ScrollContainer that contains the _tab_button_container
@export var _tab_button_scroll: ScrollContainer

## The container for tab Control nodes
@export var _tab_control_container: Control

## The overlay container for overlays
@export var _overlay_container: Control

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

## RefMap for UIPanel: PanelMenuBar
var _menu_bars: RefMap = RefMap.new()

## The current tab number
var _current_tab: int = 0

## The current visable tabs control node
var _current_visable_panel: UIPanel

## The Button Group to asign all tab buttons to
var _button_group: ButtonGroup = ButtonGroup.new()


func _ready() -> void:
	_load_default_buttons()
	
	change_to_tab(0)
	create_custom("UIDesk")
	
	_tab_button_container.add_theme_constant_override("separation", button_separation)


## Changes to a tab
func change_to_tab(p_tab_id: int) -> bool:
	if p_tab_id == _current_tab or p_tab_id > len(_tab_buttons):
		return false
	
	if _tab_controls.has_left(p_tab_id):
		if _current_visable_panel:
			Interface.fade_and_hide(_current_visable_panel)
			Interface.fade_and_hide(_menu_bars.left(_current_visable_panel))
		
		Interface.fade_and_hide(_panel_type_option)
		_current_visable_panel = _tab_controls.left(p_tab_id)
		Interface.show_and_fade(_current_visable_panel)
		
		if _current_visable_panel.get_edit_mode():
			Interface.show_and_fade(_menu_bars.left(_current_visable_panel))
		
		_edit_button.disabled = false
		_edit_button.set_pressed_no_signal(_current_visable_panel.get_edit_mode())
		
		_tab_buttons[p_tab_id].set_pressed_no_signal(true)
	
	else:
		if _current_visable_panel:
			Interface.fade_and_hide(_current_visable_panel)
			Interface.fade_and_hide(_menu_bars.left(_current_visable_panel))
		
		Interface.show_and_fade(_panel_type_option)
		
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


## Creates a custom panel tab
func create_custom(p_panel_class: String) -> UIPanel:
	if not UIDB.has_panel(p_panel_class) or _tab_controls.has_left(_current_tab):
		return null
	
	var new_panel: UIPanel = UIDB.instance_panel(p_panel_class)
	
	set_panel(new_panel, _current_tab)
	return new_panel


## Sets the UIPanel on the current tab
func set_panel(p_panel: UIPanel, p_tab: int) -> void:
	if _tab_controls.has_left(p_tab):
		_tab_controls.left(p_tab).queue_free()
	
	p_panel.set_menu_bar_visable(false)
	
	var menu_bar: PanelMenuBar = p_panel.detatch_menu_bar()
	_menu_bars.map(p_panel, menu_bar)
	
	_overlay_container.add_child(menu_bar)
	menu_bar.size.x = menu_bar_default_size
	menu_bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_KEEP_WIDTH)
	
	_tab_controls.map(p_tab, p_panel)
	_tab_control_container.add_child(p_panel)
	
	_tab_buttons[p_tab].get_child(0).set_text(default_tab_name.replace("#", str(p_tab)))
	_tab_buttons[p_tab].self_modulate = tab_button_modulate
	
	_current_visable_panel = p_panel
	_current_visable_panel.hide()
	Interface.show_and_fade(_current_visable_panel)
	Interface.fade_and_hide(_panel_type_option)
	_edit_button.disabled = false


## Gets the current tab
func get_current_tab() -> int:
	return _current_tab


## Sets the edit mode state on the current selected tab
func set_tab_edit_mode(p_edit_mode: bool) -> bool:
	if not _current_visable_panel:
		return false
	
	if p_edit_mode:
		Interface.show_and_fade(_menu_bars.left(_current_visable_panel))
	else:
		Interface.fade_and_hide(_menu_bars.left(_current_visable_panel))
	
	_current_visable_panel.set_edit_mode(p_edit_mode)
	return true


## Sets the name of a tab
func set_tab_name(p_tab_id: int, p_tab_name: String) -> bool:
	if p_tab_id > len(_tab_buttons) - 1:
		return false
	
	_tab_buttons[p_tab_id].get_child(0).text = p_tab_name
	return true


## Resets this to the default state
func reset() -> void:
	for tab: UIPanel in _tab_controls.get_right():
		tab.queue_free()
	
	for tab_button: Button in _tab_buttons:
		tab_button.queue_free()
	
	_current_tab = 0
	_tab_buttons.clear()
	_tab_controls.clear()
	_current_visable_panel = null
	_button_group = ButtonGroup.new()


## Saves all the tabs
func save() -> Dictionary:
	var tabs: Dictionary[int, Dictionary] = {
	}
	
	for tab_id: int in range(len(_tab_buttons)):
		tabs[tab_id] = {
			"name": _tab_buttons[tab_id].get_child(0).text,
			"type": _tab_controls.left(tab_id).get_class_name()
		}
	
	return {
		"tabs": tabs,
		"current": get_current_tab()
	}


## Loads all the tabs
func load(saved_data: Dictionary) -> void:
	var tabs: Array = type_convert(saved_data.get("tabs", []), TYPE_ARRAY)
	
	for tab_id: int in range(len(tabs)):
		if not tabs[tab_id] is Dictionary:
			return
		
		var tab: Dictionary = tabs[tab_id]
		var tab_class: String = type_convert(tab.get("type", ""), TYPE_STRING)
		var tab_name: String = type_convert(tab.get("name", ""), TYPE_STRING)
		
		change_to_tab(tab_id)
		var panel: UIPanel = create_custom(tab_class)
		
		if panel:
			set_tab_name(tab_id, tab_name)
			panel.load(type_convert(tab.get("settings", {}), TYPE_DICTIONARY))
		else:
			breakpoint
	
	change_to_tab(type_convert(saved_data.get("current", 0), TYPE_INT))


## Loads the default number of buttons
func _load_default_buttons() -> void:
	for i in range(max_visable_tabs + 1):
		var new_button: Button = _create_tab_button("", i)
		
		_tab_buttons.append(new_button)
		_tab_button_container.add_child(new_button)


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


## Called when the AddCustom button is pressed
func _on_add_custom_pressed() -> void:
	var current_tab: int = _current_tab
	Interface.prompt_panel_picker(self).then(func (p_panel_class: String):
		set_panel(UIDB.instance_panel(p_panel_class), current_tab)
	)

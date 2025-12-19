# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UIPopupPanelPicker extends UIPopup
## Picks panel items for the Desk


## Emitted when a panel is chosen
signal panel_chosen(panel_class: String)


## The tab container
@export var _tab_container: CustomTabContainer


## Init
func _init() -> void:
	super._init()
	
	_set_class_name("UIPopupPanelPicker")
	set_custom_accepted_signal(panel_chosen)


## Ready
func _ready() -> void:
	_reload_panels()


## Reloads the list
func _reload_panels() -> void:
	for old_tab: ScrollContainer in _tab_container.get_children():
		_tab_container.remove_tab(old_tab.index)
		old_tab.queue_free()
	
	for category: String in UIDB.get_panel_categories():
		var category_tab: ScrollContainer = ScrollContainer.new()
		category_tab.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		_tab_container.add_tab(category.capitalize(), category_tab)
		
		var grid: GridContainer = GridContainer.new()
		grid.columns = 2
		grid.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		category_tab.add_child(grid)
		
		for panel_name: String in UIDB.get_panels_in_category(category):
			grid.add_child(_create_panel_item(panel_name))


## Creates a new panel item
func _create_panel_item(p_panel_class: String) -> PanelPickerItem:
	var new_panel_item: PanelPickerItem = load("uid://db4x2kpax7p1j").instantiate()
	
	new_panel_item.set_title(p_panel_class.replace("UI", "").capitalize())
	new_panel_item.set_info(p_panel_class)
	
	#if Interface.panel_icons.has(panel_name):
		#new_panel_item.set_icon(Interface.panel_icons[panel_name])
	
	new_panel_item.pressed.connect(func () -> void:
		accept(p_panel_class)
	)
	
	return new_panel_item

# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name PanelPicker extends PanelContainer
## Picks panel items for the Desk


## Emitted when a panel is chosen
signal panel_chosen(panel: PackedScene)

## Emitted when the cancel button is pressed
signal cancel_pressed()


## The tab container
@export var _tab_container: CustomTabContainer


func _ready() -> void:
	_reload_panels()


## Reloads the list
func _reload_panels() -> void:
	for old_tab: ScrollContainer in _tab_container.get_children():
		_tab_container.remove_tab(old_tab.index)
		old_tab.queue_free()
	
	for category: String in Interface.sorted_panels:
		var category_tab: ScrollContainer = ScrollContainer.new()
		category_tab.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		_tab_container.add_tab(category.capitalize(), category_tab)
		
		var grid: GridContainer = GridContainer.new()
		grid.columns = 2
		grid.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		category_tab.add_child(grid)
		
		for panel_name: String in Interface.sorted_panels[category]:
			grid.add_child(_create_panel_item(panel_name, Interface.panels[panel_name]))


## Creates a new panel item
func _create_panel_item(panel_name: String, panel: PackedScene) -> PanelPickerItem:
	var new_panel_item: PanelPickerItem = load("res://components/PanelPicker/PanelPickerItem.tscn").instantiate()
	
	new_panel_item.set_title(panel_name.capitalize())
	new_panel_item.set_info(panel_name)
	
	if Interface.panel_icons.has(panel_name):
		new_panel_item.set_icon(Interface.panel_icons[panel_name])
	
	new_panel_item.pressed.connect(func () -> void:
		panel_chosen.emit(panel)
	)
	
	return new_panel_item

func _on_button_pressed() -> void:
	cancel_pressed.emit()

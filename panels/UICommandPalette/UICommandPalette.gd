# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name UICommandPalette extends UIPanel
## CommandPalette


## The LineEdit input
@export var line_edit: TaggedLineEdit

## The Treee for SearchMode.COMMAND
@export var command_tree: Tree

## The Tree for SearchMode.COMPONENT_SEARCH
@export var component_search_tree: Tree

## The Tree for SearchMode.COMPONENT_SEARCH flattned
@export var component_search_tree_flat: Tree

## The Tree for modes that have dynamic data
@export var dynamic_tree: Tree


## Enum for SearchMode
enum SearchMode {
	COMMAND,			## Search and run commands
	SETTINGS_MANAGER,	## Displays the SettingsManager for a given object
}

## RefMap for TreeItem: SettingsModule
var _command_items: RefMap = RefMap.new()

## Current SearchMode state
var _search_mode: SearchMode = SearchMode.COMMAND

## Mode tag state
var _mode_tag_visible: bool = false


## Ready
func _ready() -> void:
	_ready_command_mode()
	
	search_for("")


## Ready function for SearchMode.COMMAND
func _ready_command_mode() -> void:
	command_tree.create_item()
	command_tree.set_column_expand(1, false)
	command_tree.set_column_custom_minimum_width(1, 50)

	for classname: String in Interface._palette_search_index:
		for item_name: String in Interface._palette_search_index[classname]:
			var tree_item: TreeItem = command_tree.create_item()
			var module: SettingsModule = Interface._palette_search_index[classname][item_name]
			
			tree_item.set_text(0, str(classname, ": ", item_name))
			tree_item.set_icon(0, UIDB.get_class_icon(classname))
			
			tree_item.set_custom_color(1, Color(0x919191ff))
			
			match module.get_type():
				SettingsModule.Type.SETTING, SettingsModule.Type.CONTROL when module.get_data_type() == Data.Type.NULL:
					tree_item.set_text(1, "Run")
					
				SettingsModule.Type.SETTING, SettingsModule.Type.CONTROL when module.get_data_type() != Data.Type.NULL:
					tree_item.set_text(1, "Edit")
				
				SettingsModule.Type.STATUS:
					tree_item.set_text(1, "View")
			
			_command_items.map(tree_item, module)


## Processes the given text and changes mode if needed
func process_text(p_text: String) -> void:
	search_for(p_text)


## Searches for a string
func search_for(p_search_string: String) -> void:
	var items_to_display: Array[Dictionary]
	var search_string: String = p_search_string.to_lower()
	var search_tree: Tree = null
	
	match _search_mode:
		SearchMode.COMMAND:
			for classname: String in Interface._palette_search_index:
				for item_name: String in Interface._palette_search_index[classname]:
					items_to_display.append({
						"item_name": item_name,
						"similarity": item_name.similarity(search_string) if p_search_string else 0.0,
						"tree_item": _command_items.right(Interface._palette_search_index[classname][item_name])
					})
			
			search_tree = command_tree
	
	items_to_display.sort_custom(_sort_items.bind(search_string))
	items_to_display.reverse()
	
	for item: Dictionary in items_to_display:
		item.tree_item.move_before(search_tree.get_root().get_child(0))
	
	search_tree.get_root().get_child(0).select(0)
	search_tree.ensure_cursor_is_visible()


## Take focus to the input
func focus() -> void:
	line_edit.grab_focus()


## Activates an item
func activate_item(p_tree_item: TreeItem) -> void:
	match _search_mode:
		SearchMode.COMMAND:
			var module: SettingsModule = _command_items.left(p_tree_item)
			
			match module.get_data_type():
				Data.Type.NULL:
					module.get_setter().call()
					
	
	close_request.emit()


## Sorts items
func _sort_items(p_a: Dictionary, p_b: Dictionary, p_search_string: String) -> bool:
	if p_search_string and len(p_search_string) < 3:
		return (p_a.item_name as String).to_lower().begins_with(p_search_string[0])
	elif p_search_string:
		return p_a.similarity > p_b.similarity
	else:
		return (p_a.item_name as String).naturalnocasecmp_to(p_b.item_name)


## Selectes the next item in the tree
func _select_next(p_tree: Tree) -> void:
	var current: TreeItem = p_tree.get_selected()
	var next_item: TreeItem = current.get_next_visible(true) if current else p_tree.get_root().get_child(0)
	
	if next_item:
		next_item.select(0)
	
	p_tree.ensure_cursor_is_visible()


## Selectes the next item in the tree
func _select_prev(p_tree: Tree) -> void:
	var current: TreeItem = p_tree.get_selected()
	var next_item: TreeItem = current.get_prev_visible(true) if current else p_tree.get_root().get_child(0)
	
	if next_item:
		next_item.select(0)
	
	p_tree.ensure_cursor_is_visible()


## Called when text is submitted in the list
func _on_line_edit_text_submitted(p_new_text: String) -> void:
	match _search_mode:
		SearchMode.COMMAND:
			if not command_tree.get_selected():
				return
			
			activate_item(command_tree.get_selected())


## Called when the text is changed in the LineEdit
func _on_line_edit_text_changed(p_new_text: String) -> void:
	process_text(p_new_text)


## Called for each GUI input on the lineedit
func _on_line_edit_gui_input(p_event: InputEvent) -> void:
	if p_event.is_action_released("ui_down"):
		_select_next(command_tree)
	
	if p_event.is_action_released("ui_up"):
		_select_prev(command_tree)


## Called when an item is activated in the tree
func _on_command_tree_item_activated() -> void:
	activate_item(command_tree.get_selected())


## Called when a tag is removed from the SearchBox
func _on_line_edit_tag_removed(p_id: Variant) -> void:
	_mode_tag_visible = false
	process_text(line_edit.get_text())

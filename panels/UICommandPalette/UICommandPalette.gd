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
	COMPONENT_SEARCH,	## Search for EngineComponents in a class
	SETTINGS_MANAGER,	## Displays the SettingsManager for a given object
}

## RefMap for TreeItem: SettingsModule
var _command_items: RefMap = RefMap.new()

## RefMap for TreeItem: Script(EngineComponent)
var _component_item: RefMap = RefMap.new()

## Current SearchMode state
var _search_mode: SearchMode = SearchMode.COMMAND

## Mode tag state
var _mode_tag_visible: bool = false


## Ready
func _ready() -> void:
	_ready_command_mode()
	_ready_component_search_mode()
	_ready_dymanic_tree()
	
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


## Ready function for SearchMode.COMPONENT_SEARCH
func _ready_component_search_mode() -> void:
	component_search_tree.create_item()
	component_search_tree.set_column_expand(1, false)
	component_search_tree.set_column_custom_minimum_width(1, 50)
	
	component_search_tree_flat.create_item()
	component_search_tree_flat.set_column_expand(1, false)
	component_search_tree_flat.set_column_custom_minimum_width(1, 50)
	
	var class_tree: Dictionary = ClassList.get_global_class_tree()
	
	_climb_branch.call(component_search_tree.get_root(), class_tree)


## Climbs a branch on the class tree
func _climb_branch(tree_branch: TreeItem, data_branch: Dictionary) -> void:
	for key: String in data_branch.keys():
		if ClassList.is_class_hidden(key):
			continue
		
		var value: Variant = data_branch[key]
		var new_branch = tree_branch.create_child()
		
		new_branch.set_text(0, key)
		new_branch.set_icon(0, UIDB.get_class_icon(key))
		
		new_branch.set_custom_color(1, Color(0x919191ff))
		new_branch.set_text(1, "Enter")
		
		if value is Dictionary:
			_climb_branch.call(new_branch, value)
		else:
			var flat_item: TreeItem = component_search_tree_flat.create_item()
			
			flat_item.set_text(0, key)
			flat_item.set_icon(0, UIDB.get_class_icon(key))
			
			flat_item.set_custom_color(1, Color(0x919191ff))
			flat_item.set_text(1, "Enter")
			
			_component_item.map(flat_item, key)


## Ready the dynamic mode tree
func _ready_dymanic_tree() -> void: 
	dynamic_tree.create_item()


## Processes the given text and changes mode if needed
func process_text(p_text: String) -> void:
	command_tree.hide()
	component_search_tree.hide()
	component_search_tree_flat.hide()
	dynamic_tree.hide()
	
	if not _mode_tag_visible:
		match p_text[0] if p_text else "":
			"@":
				_search_mode = SearchMode.COMPONENT_SEARCH
				_mode_tag_visible = true
				component_search_tree.show()
				
				line_edit.create_tag("@")
				line_edit.set_text("")
			_:
				_search_mode = SearchMode.COMMAND
				command_tree.show()
		
		search_for(p_text.substr(1))
	
	else:
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
		
		SearchMode.COMPONENT_SEARCH:
			component_search_tree.hide()
			component_search_tree_flat.hide()
			
			if not p_search_string:
				component_search_tree.show()
				return
			
			search_tree = component_search_tree_flat
			component_search_tree_flat.show()
			
			for classname: String in ClassList.get_script_map().keys():
				if ClassList.is_class_hidden(classname):
					continue
				
				items_to_display.append({
					"item_name": classname,
					"similarity": classname.similarity(search_string) if p_search_string else 0.0,
					"tree_item": _component_item.right(classname)
				})
	
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


## Called when text is submitted in the list
func _on_line_edit_text_submitted(p_new_text: String) -> void:
	pass
	#if not tree.get_selected():
		#return
	#
	#activate_item(tree.get_selected())


## Called when the text is changed in the LineEdit
func _on_line_edit_text_changed(p_new_text: String) -> void:
	process_text(p_new_text)


## Called for each GUI input on the lineedit
func _on_line_edit_gui_input(p_event: InputEvent) -> void:
	pass
	#if p_event.is_action_released("ui_down"):
		#tree.grab_focus()
		#
		#if tree.get_root().get_child_count():
			#tree.get_root().get_child(0).select(0)


## Called when an item is activated in the tree
func _on_tree_item_activated() -> void:
	activate_item(command_tree.get_selected())


## Called when a tag is removed from the SearchBox
func _on_line_edit_tag_removed(p_id: Variant) -> void:
	_mode_tag_visible = false
	process_text(line_edit.get_text())

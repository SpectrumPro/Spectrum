# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

@tool
extends Control
## GUI Component for a list view.

signal edit_requested(items: Array)
signal delete_requested(items: Array)
signal take_requested(items: Array)
signal add_requested()
signal selection_changed(items: Array)

@export var show_tool_bar: bool = true : set = set_show_tool_bar
@export var show_new: bool = true : set = set_show_new
@export var show_select: bool = true : set = set_show_select
@export var show_invert: bool = true : set = set_show_invert
@export var show_take: bool = true : set = set_show_take
@export var show_edit: bool = true : set = set_show_edit
@export var show_delete: bool = true : set = set_show_delete
@export var show_separators: bool = true : set = set_show_separators

@export var buttons_enabled: bool = true : set = set_buttons_enabled
@export var allow_multi_select: bool = true

@onready var item_container: VBoxContainer = self.get_node("PanelContainer2/ScrollContainer/ItemContainer")

var currently_selected_items: Array = []
var last_selected_item: Control

var object_refs: Dictionary

func _ready() -> void:
	set_show_tool_bar(show_tool_bar)
	set_show_new(show_new)
	set_show_select(show_select)
	set_show_invert(show_invert)
	set_show_take(show_take)
	set_show_edit(show_edit)
	set_show_delete(show_delete)
	set_show_separators(show_separators)


func add_items(items: Array) -> void:
	## Adds an item to the list
	
	for item in items:
		if "uuid" in item and "name" in item:
			var new_item_node: Control = Globals.components.list_item.instantiate()
			new_item_node.set_item_name(item.name)
			
			new_item_node.control_node = self
			new_item_node.name = item.uuid
			new_item_node.select_requested.connect(self.on_list_item_select_request)
			
			item_container.add_child(new_item_node)
			object_refs[new_item_node] = item


func remove_all() -> void:
	## Removes all items from the list
	
	for item in item_container.get_children():
		item_container.remove_child(item)
		item.queue_free()


func on_list_item_select_request(selected_item: Control) -> void:
	if Input.is_key_pressed(KEY_SHIFT) and last_selected_item and allow_multi_select:
		var children: Array[Node] = item_container.get_children()
		var pos_1: int = children.find(last_selected_item)
		var pos_2: int = children.find(selected_item)
		
		if pos_1 > pos_2:
			var x = pos_1
			pos_1 = pos_2
			pos_2 = x
		
		var items_to_select: Array = []
		
		for i in range(pos_1, pos_2+1):
			items_to_select.append(children[i])
		
		currently_selected_items = items_to_select
		
	else:
		last_selected_item = selected_item
		currently_selected_items = [selected_item]
	
	_update_selected()


func _update_selected() -> void:
	for item: Control in item_container.get_children():
		item.set_highlighted(false)
	
	for item: Control in currently_selected_items:
		item.set_highlighted(true)
		
	selection_changed.emit(get_objects_from_nodes(currently_selected_items))


func get_objects_from_nodes(items: Array) -> Array:
	## Converts a list of list Item nodes into the objects they are representing
	
	var object_list: Array = []
	
	for item in items:
		object_list.append(object_refs[item])
	
	return object_list


func set_buttons_enabled(state: bool):
	
	buttons_enabled = state
	
	for node: Node in $ToolBarContainer/HBoxContainer.get_children():
		if node is Button:
			node.disabled = not buttons_enabled


#region Button Callbacks

func _on_new_pressed() -> void:
	add_requested.emit()


func _on_select_all_pressed() -> void:
	currently_selected_items = item_container.get_children()
	_update_selected()


func _on_select_none_pressed() -> void:
	currently_selected_items = []
	_update_selected()


func _on_select_invert_pressed() -> void:
	var all_items: Array = item_container.get_children()
	
	for item: Control in currently_selected_items:
		all_items.erase(item)
		
	currently_selected_items = all_items
	_update_selected()


func _on_take_selection_pressed() -> void:
	take_requested.emit(get_objects_from_nodes(currently_selected_items))


func _on_edit_pressed() -> void:
	edit_requested.emit(get_objects_from_nodes(currently_selected_items))


func _on_delete_pressed() -> void:
	delete_requested.emit(get_objects_from_nodes(currently_selected_items))

#endregion


#region UI displaying functions
func set_show_tool_bar(is_visible) -> void:
	show_tool_bar = is_visible
	if is_node_ready():
		$ToolBarContainer.visible = is_visible


func set_show_edit(is_visible) -> void:
	show_edit = is_visible
	if is_node_ready():
		$ToolBarContainer/HBoxContainer/Edit.visible = is_visible


func set_show_delete(is_visible) -> void:
	show_delete = is_visible
	if is_node_ready():
		$ToolBarContainer/HBoxContainer/Delete.visible = is_visible


func set_show_select(is_visible) -> void:
	show_select = is_visible
	if is_node_ready():
		$ToolBarContainer/HBoxContainer/SelectAll.visible = is_visible
		$ToolBarContainer/HBoxContainer/SelectNone.visible = is_visible


func set_show_invert(is_visible) -> void:
	show_invert = is_visible
	if is_node_ready():
		$ToolBarContainer/HBoxContainer/SelectInvert.visible = is_visible


func set_show_new(is_visible) -> void:
	show_new = is_visible
	if is_node_ready():
		$ToolBarContainer/HBoxContainer/New.visible = is_visible
		$ToolBarContainer/HBoxContainer/VSeparator1.visible = is_visible


func set_show_take(is_visible) -> void:
	show_take = is_visible
	if is_node_ready():
		$ToolBarContainer/HBoxContainer/TakeSelection.visible = is_visible


func set_show_separators(is_visible) -> void:
	show_separators = is_visible
	if is_node_ready():
		$ToolBarContainer/HBoxContainer/VSeparator1.visible = is_visible
		$ToolBarContainer/HBoxContainer/VSeparator2.visible = is_visible
#endregion

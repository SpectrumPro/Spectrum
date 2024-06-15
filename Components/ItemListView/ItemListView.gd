# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

@tool
class_name ItemListView extends Control
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
	set_show_separators(show_separators)
	set_show_tool_bar(show_tool_bar)
	set_show_new(show_new)
	set_show_select(show_select)
	set_show_invert(show_invert)
	set_show_take(show_take)
	set_show_edit(show_edit)
	set_show_delete(show_delete)


func add_items(items: Array, chips: Array = [], name_method: String = "") -> void:
	## Adds an item to the list
	
	$PanelContainer2/ConfirmationBox.hide()
	
	
	for item in items:
		var new_item_node: Control = Interface.components.ListItem.instantiate()
		
		if item is Object or item is Dictionary and _is_valid_object(item):
			new_item_node.set_item_name(item.name)
			
			new_item_node.name = item.uuid
			new_item_node.select_requested.connect(self._on_list_item_select_request)
			
			for chip: Array in chips:
				new_item_node.add_chip(item, chip[0], item.get(chip[1]))
			
			if name_method:
				new_item_node.set_name_method(item.get(name_method))
		
		else:
			new_item_node.set_item_name(str(item))
			
			new_item_node.name = str(item)
			new_item_node.select_requested.connect(self._on_list_item_select_request)
		
		item_container.add_child(new_item_node)
		object_refs[new_item_node] = item


func remove_all() -> void:
	## Removes all items from the list
	
	$PanelContainer2/ConfirmationBox.hide()
	
	
	object_refs = {}
	last_selected_item = null
	currently_selected_items = []
	
	for item in item_container.get_children():
		item_container.remove_child(item)
		item.queue_free()


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


func set_selected(items: Array) -> void:
	## Sets the selected list items
	
	currently_selected_items = []
	
	for item in items:
		if item is Object or item is Dictionary:
			if item_container.has_node(item.uuid):
				currently_selected_items.append(item)
		else:
			if item_container.has_node(str(item)):
				currently_selected_items.append(item)
			
	
	if currently_selected_items and not last_selected_item:
		last_selected_item = item_container.get_node(currently_selected_items[-1].uuid)
	
	_update_selected()


func _on_list_item_select_request(selected_item: Control) -> void:
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
		
		selection_changed.emit(get_objects_from_nodes(items_to_select))
		
	else:
		last_selected_item = selected_item
		selection_changed.emit(get_objects_from_nodes([selected_item]))



func _update_selected(no_signal: bool = false) -> void:
	for item: Control in item_container.get_children():
		item.set_highlighted(false)
	
	for item in currently_selected_items:
		if item is Object or item is Dictionary:
			item_container.get_node(item.uuid).set_highlighted(true)
		else:
			item_container.get_node(str(item)).set_highlighted(true)


func _is_valid_object(object: Variant) -> bool:
	## Checks if an object is valid for use in an item list, object must have a uuid and name
	
	if object is Object and "uuid" in object and "name" in object:
		return true
	else:
		return false


#region Button Callbacks

func _on_new_pressed() -> void:
	add_requested.emit()


func _on_select_all_pressed() -> void:
	if object_refs:
		selection_changed.emit(get_objects_from_nodes( item_container.get_children()))


func _on_select_none_pressed() -> void:
	if object_refs:
		selection_changed.emit([])


func _on_select_invert_pressed() -> void:
	if object_refs:
		var all_items: Array = object_refs.values()
		
		for item: Object in currently_selected_items:
			all_items.erase(item)
		
		selection_changed.emit(all_items)


func _on_take_selection_pressed() -> void:
	if currently_selected_items:
		take_requested.emit(currently_selected_items)


func _on_edit_pressed() -> void:
	edit_requested.emit(currently_selected_items)


func _on_delete_pressed() -> void:
	if currently_selected_items:
		
		$PanelContainer2/ConfirmationBox.show()
		
		var delete_signal = func ():
			delete_requested.emit(currently_selected_items)
			$PanelContainer2/ConfirmationBox.hide()
			
		
		$PanelContainer2/ConfirmationBox/VBoxContainer/HBoxContainer/DELETE.pressed.connect(delete_signal)
		
		$PanelContainer2/ConfirmationBox/VBoxContainer/HBoxContainer/Cancel.pressed.connect(func():
			$PanelContainer2/ConfirmationBox.hide()
			$PanelContainer2/ConfirmationBox/VBoxContainer/HBoxContainer/DELETE.pressed.disconnect(delete_signal)
		)

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

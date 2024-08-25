# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

@tool
class_name ItemListView extends Control
## GUI component for a list view.


## Emitted when the edit button is pressed
signal edit_requested(items: Array)

## Emitted when the delete button is pressed, while items are selected
signal delete_requested(items: Array)

## Emitted when the take button is presses, while items are selected
signal take_requested(items: Array)

## Emitted whent the add button is press
signal add_requested()

## Emitted when the selection is changed
signal selection_changed(items: Array)


@export var show_tool_bar: bool = true : set = set_show_tool_bar ## Show the whole tool bar
@export var show_new: bool = true : set = set_show_new ## Show the Add button
@export var show_select: bool = true : set = set_show_select ## Show the selection all and none buttons
@export var show_invert: bool = true : set = set_show_invert ## Shows the selection inver button
@export var show_take: bool = true : set = set_show_take ## Shows the take button
@export var show_edit: bool = true : set = set_show_edit ## Shows the edit button
@export var show_delete: bool = true : set = set_show_delete ## Shows the delete button
@export var show_separators: bool = true : set = set_show_separators ## Shows the separators in the tool bar

@export var buttons_enabled: bool = true : set = set_buttons_enabled ## Shows or hides all the button in the ui
@export var allow_multi_select: bool = true ## If the user should be able to select mutiple items at once

@onready var item_container: VBoxContainer = self.get_node("PanelContainer2/ScrollContainer/ItemContainer")

## All the currently selected items
var currently_selected_items: Array = []

## All the highlighted selected items
var currently_highlighted_items: Array = []

## The most recently selected item
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
	
	$PanelContainer2/ConfirmationBox/VBoxContainer/HBoxContainer/DELETE.pressed.connect(self._on_delete_confirmation)
	
	$PanelContainer2/ConfirmationBox/VBoxContainer/HBoxContainer/Cancel.pressed.connect(func():
		$PanelContainer2/ConfirmationBox.hide()
	)
	
	Interface.kiosk_mode_changed.connect(_on_kiosk_mode_changed)


func _on_kiosk_mode_changed(kiosk_mode: bool) -> void:
	$ToolBarContainer.visible = false if kiosk_mode else (true if show_tool_bar else false)


## Adds an item to the list
func add_items(items: Array, chips: Array = [], name_method: String = "", name_changed_signal: String = "") -> void:
	
	$PanelContainer2/ConfirmationBox.hide()
	
	
	for item in items:
		var new_item_node: ListItem = Interface.components.ListItem.instantiate()
		
		if item is Object or item is Dictionary and _is_valid_object(item):
			new_item_node.set_item_name(item.name)
			
			new_item_node.name = item.uuid
			new_item_node.select_requested.connect(self._on_list_item_select_request)
			
			for chip: Array in chips:
				if item.get(chip[1]):
					new_item_node.add_chip(item, chip[0], item.get(chip[1]))
			
			if name_method:
				new_item_node.set_name_method(item.get(name_method))
			
			if name_changed_signal:
				new_item_node.set_name_changed_signal(item.get(name_changed_signal))
				
		
		else:
			new_item_node.set_item_name(str(item))
			
			new_item_node.name = str(item)
			new_item_node.select_requested.connect(self._on_list_item_select_request)
		
		item_container.add_child(new_item_node)
		object_refs[new_item_node] = item


## Removes all items from the list
func remove_all() -> void:
	
	$PanelContainer2/ConfirmationBox.hide()
	
	
	object_refs = {}
	last_selected_item = null
	currently_selected_items = []
	
	for item in item_container.get_children():
		item_container.remove_child(item)
		item.queue_free()


## Converts a list of list Item nodes into the objects they are representing
func get_objects_from_nodes(items: Array) -> Array:
	
	var object_list: Array = []
	
	for item in items:
		object_list.append(object_refs[item])
	
	return object_list


func get_names_from_nodes(nodes: Array) -> Array:
	var object_list: Array = []
	
	for node in nodes:
		object_list.append((node.name))
	
	return object_list


## Enables or dissables the buttons
func set_buttons_enabled(state: bool):
	
	buttons_enabled = state
	
	for node: Node in $ToolBarContainer/HBoxContainer.get_children():
		if node is Button:
			node.disabled = not buttons_enabled


## Sets the selected list items
func set_selected(items: Array) -> void:
	
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


## Sets the highlighted list items
func set_highlighted(items: Array) -> void:
	
	currently_highlighted_items = []
	
	for item in items:
		if item is Object or item is Dictionary:
			if item_container.has_node(item.uuid):
				currently_highlighted_items.append(item)
		else:
			if item_container.has_node(str(item)):
				currently_highlighted_items.append(item)
	
	_update_highlighted()


func _on_list_item_select_request(selected_item: ListItem) -> void:
	var new_items: Array = []
	
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
		
		new_items = items_to_select
		
		selection_changed.emit(get_objects_from_nodes(items_to_select))
		
	else:
		last_selected_item = selected_item
		new_items = [selected_item]
		
		selection_changed.emit(get_objects_from_nodes([selected_item]))
	
	if Input.is_key_pressed(KEY_ALT):
		DisplayServer.clipboard_set(str(get_names_from_nodes(new_items)))


func _update_selected() -> void:
	for item: Control in item_container.get_children():
		item.set_selected(false)
	
	for item in currently_selected_items:
		if item is Object or item is Dictionary:
			item_container.get_node(item.uuid).set_selected(true)
		else:
			item_container.get_node(str(item)).set_selected(true)


func _update_highlighted() -> void:
	for item: Control in item_container.get_children():
		item.set_highlighted(false)
	
	for item in currently_highlighted_items:
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


func _on_delete_confirmation() -> void:
	delete_requested.emit(currently_selected_items)


func _on_item_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_mask == MOUSE_BUTTON_LEFT:
		selection_changed.emit([])

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


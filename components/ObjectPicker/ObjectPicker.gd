# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name ObjectPicker extends PanelContainer
## Object picker to select engine components, uses the ComponentDB


## Emitted when the user presses the select button
signal selection_confirmed(selection: Array[EngineComponent])

## Emitted if the use canceled the selection
signal selection_canceled()


## The tree node
@onready var tree: Tree = $VBoxContainer/Tree


## Stores all the items that are in the tree, stored as {"class_name": {"uuid", TreeItem}}
var tree_items: Dictionary = {}

## Contains all the currentl selected items
var selected_items: Array[EngineComponent] = []

## Allow and deny lists for the filt er
## Everything in the allow list will be shown, and anything not will be hidden. You will need to set this var directley, or use the add / remove methods
## Modifying it using .append, or .erase will not work.
var filter_allow_list: Array = [] : 
	set(value):
		filter_allow_list = value
		_update_filter()


## Allows the user to set a filter, if set to false, it will lock the filter
var user_filtering: bool = true : set = set_user_filtering

## Select mode
enum SelectMode {Single = 0, Multi = 2}


## The root node TreeItem
var _root_item: TreeItem = null

## Stores the bound callables for a components name_changed signal
var _signal_connections: Dictionary = {}

## Stores all the parent nodes, so they don't get added to the selection in single select mode
var _parent_nodes: Array[TreeItem] = []

## Stores a refernce back to the orignal object, keyed by the treeitem object, {TreeItem: EngineComponent}
var _component_refs: Dictionary = {}

## Stores a refernce to all the filter buttons, by the class name. {"class_name": Button}
var _filter_buttons: Dictionary = {}


func _ready() -> void:
	ComponentDB.component_added.connect(_add_component)
	ComponentDB.component_removed.connect(_remove_component)
	
	Core.resetting.connect(_reset)
	_reset()
	_update_selection_label()
	_update_filter()


## Resets the tree and root node
func _reset() -> void:
	filter_allow_list = []
	selected_items = []
	tree_items = {}
	
	_signal_connections = {}
	_parent_nodes = []
	_component_refs = {}
	_filter_buttons = {}
	
	tree.clear()
	
	_root_item = tree.create_item()
	_root_item.set_text(0, "Components")


## Sets the selection mode on the tree node
func set_select_mode(select_mode: SelectMode) -> void:
	tree.set_select_mode(select_mode as Tree.SelectMode)
	
	var title: String = ""
	match select_mode:
		SelectMode.Single:
			title = "Select an Object:"
		SelectMode.Multi:
			title = "Select Objects:"
	
	$VBoxContainer/PanelContainer/HBoxContainer/Title.text = title


## Allows the user to filter for classes, if false, the filter is locked.
func set_user_filtering(p_user_filtering: bool) -> void:
	user_filtering = p_user_filtering
	for button: Button in _filter_buttons.values():
		button.disabled = not user_filtering


## Adds an item to the filter
func add_to_filter(class_name_string: String) -> void:
	filter_allow_list.append(class_name_string)
	_update_filter()


## Removes and item from the filter
func remove_from_filter(class_name_string: String) -> void:
	filter_allow_list.erase(class_name_string)
	_update_filter()


## Adds a component to the tree
func _add_component(component: EngineComponent) -> void:
	var parent_node: TreeItem = null
	
	if component.self_class_name in tree_items:
		parent_node = tree_items[component.self_class_name].parent
	else:
		parent_node = tree.create_item(_root_item)
		
		var parent_name: String = component.self_class_name.capitalize()
		if not parent_name.ends_with("s"):
			parent_name += "s"
			
		parent_node.set_text(0, parent_name)
		parent_node.set_icon(0, component.icon)
		
		tree_items[component.self_class_name] = {"parent": parent_node}
	
	var item: TreeItem = tree.create_item(parent_node)
	item.set_icon(0, component.icon)
	item.set_text(0, component.name)
	
	tree_items[component.self_class_name][component.uuid] = item
	_component_refs[item] = component
	
	_signal_connections[component] = _on_component_name_changed.bind(component)
	component.name_changed.connect(_signal_connections[component])
	
	_sort(component.self_class_name)
	_update_filter()


## Removes a component from the list
func _remove_component(component: EngineComponent) -> void:
	component.name_changed.disconnect(_signal_connections[component])
	
	var tree_item: TreeItem = tree_items[component.self_class_name][component.uuid]
	var parent_node: TreeItem = tree_items[component.self_class_name].parent
	parent_node.remove_child(tree_item)
	
	tree_items[component.self_class_name].erase(component.uuid)
	if len(tree_items[component.self_class_name].values()) == 1:
		_root_item.remove_child(parent_node)
		tree_items.erase(component.self_class_name)
		_component_refs.erase(tree_item)
	
	tree_item.free()


## Callback for when a component emits name_changed
func _on_component_name_changed(new_name: String, component: EngineComponent) -> void:
	tree_items[component.self_class_name][component.uuid].set_text(0, new_name)
	_sort(component.self_class_name)


## Sorts a category by name
func _sort(category: String) -> void:
	var tree_item_dictionary: Dictionary = tree_items[category].duplicate()
	tree_item_dictionary.erase("parent")
	
	var sorted_uuids: Array = tree_item_dictionary.keys()
	sorted_uuids.sort_custom(func(a, b): 
		var a_name = ComponentDB.components[a].name
		var b_name = ComponentDB.components[b].name
		return a_name.naturalnocasecmp_to(b_name) < 0
	)
	
	var current_child_array: Array = tree_items[category].parent.get_children()
	
	for i in range(len(sorted_uuids)):
		var uuid: String = sorted_uuids[i]
		
		(tree_items[category][uuid] as TreeItem).move_before(current_child_array[-1])
	(tree_items[category][sorted_uuids[-1]] as TreeItem).move_after(current_child_array[-1])


## Updates the selection label with the names of all the current selected items
func _update_selection_label() -> void:
	var name_list: String = ""
	
	if selected_items:
		for object: EngineComponent in selected_items:
			name_list += object.name + ", "
		name_list = name_list.left(-2)
	else:
		name_list = "Select An Item..."
	
	$VBoxContainer/PanelContainer/HBoxContainer/PanelContainer/SelectionLabel.text = name_list
	$VBoxContainer/PanelContainer/HBoxContainer/Select.disabled = not selected_items


## Updates the filter, to show and hide classes
func _update_filter() -> void:
	for class_name_string: String in tree_items:
		var is_filtred_for: bool = not class_name_string in filter_allow_list and filter_allow_list
		(tree_items[class_name_string].parent as TreeItem).visible = not is_filtred_for
		
		if class_name_string in _filter_buttons:
			#(_filter_buttons[class_name_string] as Button).set_pressed_no_signal(not is_filtred_for)
			pass
		else:
			_filter_buttons[class_name_string] = _create_filter_class_button(class_name_string)
			$VBoxContainer/PanelContainer/HBoxContainer/FilterButtonContainer.add_child(_filter_buttons[class_name_string])

 
func _create_filter_class_button(class_name_string: String) -> Button:
	var filter_button: Button = Button.new()
	filter_button.icon = Interface.get_class_icon(class_name_string)
	filter_button.toggle_mode = true
	
	var tool_tip_name: String = class_name_string.capitalize()
	if not tool_tip_name.ends_with("s"):
		tool_tip_name += "s"
	
	filter_button.tooltip_text = "Filter for: " + tool_tip_name
	
	filter_button.toggled.connect(func (state: bool) -> void:
		if state:
			add_to_filter(class_name_string)
		else:
			remove_from_filter(class_name_string)
	)
	
	filter_button.set_pressed_no_signal(class_name_string in filter_allow_list)
	filter_button.disabled = not user_filtering
	
	return filter_button


## Called when an item is (de)selected in the tree
func _on_tree_multi_selected(item: TreeItem, column: int, selected: bool) -> void:
	if item not in _component_refs:
		return
	
	var object: EngineComponent = _component_refs[item]
	
	if selected and not object in selected_items:
		selected_items.append(object)
	elif not selected and object in selected_items:
		selected_items.erase(object)
	
	_update_selection_label()


func _on_tree_item_selected() -> void:
	if tree.select_mode == Tree.SelectMode.SELECT_MULTI:
		return
	
	var item: TreeItem = tree.get_selected()
	if item in _component_refs:
		selected_items = [_component_refs[item]]
	else:
		selected_items = []
	
	_update_selection_label()
	


func _on_select_pressed() -> void:
	selection_confirmed.emit(selected_items)


func _on_cancel_pressed() -> void:
	selection_canceled.emit()

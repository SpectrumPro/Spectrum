# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name ObjectPicker extends PanelContainer
## Object picker to select engine components, uses the ComponentDB


## Emitted when the user presses the select button
signal selection_confirmed(selection: Array[EngineComponent])

## Emitted if the use canceled the selection
signal selection_canceled()


## The tree node
@export var _tree: Tree = null

## Vbox that contains all the filter buttons
@export var _filter_container: VBoxContainer = null

## The selection label
@export var _selection_label: Label = null

## The title
@export var _title: Label = null

## The select button
@export var _select_button: Button = null

## Object picker main panel
@export var _object_picker_main: VBoxContainer

## The built-in create component panel
@export var _create_component: CreateComponent


## Stores all the items that are in the tree, stored as {"class_name": {"uuid", TreeItem}}
var tree_items: Dictionary = {}

## Contains all the currentl selected items
var selected_items: Array[EngineComponent] = []

## Allow and deny lists for the filt er
## Everything in the allow list will be shown, and anything not will be hidden. You will need to set this var directley, or use the add / remove methods
## Modifying it using .append, or .erase will not work.
var filter: String = "" : 
	set(value):
		filter = value
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
	
	_tree.set_column_title(0, "Component")
	_tree.set_column_title(1, "CID")
	_tree.set_column_expand(1, false)
	
	for component: EngineComponent in ComponentDB.components.values():
		_add_component(component)
	
	_create_component.set_mode(CreateComponent.Mode.Component)


## Resets the tree and root node
func _reset() -> void:
	filter = ""
	selected_items = []
	tree_items = {}
	
	_signal_connections = {}
	_parent_nodes = []
	_component_refs = {}
	_filter_buttons = {}
	
	_tree.clear()
	
	_root_item = _tree.create_item()
	_root_item.set_text(0, "Components")


## Sets the selection mode on the tree node
func set_select_mode(select_mode: SelectMode) -> void:
	_tree.set_select_mode(select_mode as Tree.SelectMode)
	
	var title: String = ""
	match select_mode:
		SelectMode.Single:
			title = "Select an Object:"
		SelectMode.Multi:
			title = "Select Objects:"
	
	_title.text = title


## Allows the user to filter for classes, if false, the filter is locked.
func set_user_filtering(p_user_filtering: bool) -> void:
	user_filtering = p_user_filtering
	for button: Button in _filter_buttons.values():
		button.disabled = not user_filtering


## Adds a component to the tree
func _add_component(component: EngineComponent) -> void:
	if ClassList.is_class_hidden(component.self_class_name):
		return
	
	var parent_node: TreeItem = null
	
	if component.self_class_name in tree_items:
		parent_node = tree_items[component.self_class_name].parent
	else:
		parent_node = _tree.create_item(_root_item)
		
		var parent_name: String = component.self_class_name.capitalize()
		if not parent_name.ends_with("s"):
			parent_name += "s"
			
		parent_node.set_text(0, parent_name)
		parent_node.set_icon(0, Interface.get_class_icon(component.self_class_name))
		parent_node.set_custom_color(0, Color.WEB_GRAY)
		
		tree_items[component.self_class_name] = {"parent": parent_node}
	
	var item: TreeItem = _tree.create_item(parent_node)
	item.set_icon(0, Interface.get_class_icon(component.self_class_name))
	item.set_text(0, component.name)
	item.set_text(1, str(component.cid()))
	
	tree_items[component.self_class_name][component.uuid] = item
	_component_refs[item] = component
	
	_signal_connections[component] = _on_component_name_changed.bind(component)
	component.name_changed.connect(_signal_connections[component])
	component.cid_changed.connect(_on_component_cid_changed.bind(component))
	
	_sort(component.self_class_name)
	_update_filter()


## Removes a component from the list
func _remove_component(component: EngineComponent) -> void:
	if not component in _component_refs.values():
		return
	
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


## Callback for when a component's CID is changed
func _on_component_cid_changed(cid: int, component: EngineComponent) -> void:
	tree_items[component.self_class_name][component.uuid].set_text(1, str(cid))
	_sort(component.self_class_name)


## Sorts a category by name
func _sort(category: String) -> void:
	var tree_item_dictionary: Dictionary = tree_items[category].duplicate()
	tree_item_dictionary.erase("parent")
	
	var sorted_uuids: Array = tree_item_dictionary.keys()
	sorted_uuids.sort_custom(func(a, b): 
		var a_cid: int = ComponentDB.components[a].cid()
		var b_cid: int = ComponentDB.components[b].cid()
		return a_cid < b_cid
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
	
	_selection_label.text = name_list
	_select_button.disabled = not selected_items


## Updates the filter, to show and hide classes
func _update_filter() -> void:
	for class_name_string: String in tree_items:
		var is_filtred_for: bool = not ClassList.does_class_inherit(class_name_string, filter) and filter
		(tree_items[class_name_string].parent as TreeItem).visible = not is_filtred_for
		
		if class_name_string in _filter_buttons:
			(_filter_buttons[class_name_string] as Button).set_pressed_no_signal(class_name_string == filter)
		else:
			_filter_buttons[class_name_string] = _create_filter_class_button(class_name_string)
			_filter_container.add_child(_filter_buttons[class_name_string])
	
	selected_items = []
	_update_selection_label()
	_create_component.set_class_filter(filter)

 
func _create_filter_class_button(class_name_string: String) -> Button:
	var filter_button: Button = Button.new()
	filter_button.icon = Interface.get_class_icon(class_name_string)
	filter_button.toggle_mode = true
	
	var tool_tip_name: String = class_name_string.capitalize()
	if not tool_tip_name.ends_with("s"):
		tool_tip_name += "s"
	
	filter_button.tooltip_text = "Filter for: " + tool_tip_name
	
	filter_button.toggled.connect(func (state: bool) -> void:
		filter = class_name_string
	)
	
	filter_button.set_pressed_no_signal(class_name_string == class_name_string)
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
	if _tree.select_mode == Tree.SelectMode.SELECT_MULTI:
		return
	
	var item: TreeItem = _tree.get_selected()
	if item in _component_refs:
		selected_items = [_component_refs[item]]
	else:
		selected_items = []
	
	_update_selection_label()


## Called when an item is dubble clicked
func _on_tree_item_activated() -> void:
	var item: TreeItem = _tree.get_selected()
	if item in _component_refs:
		selected_items = [_component_refs[item]]
		_on_select_pressed()


## Called when the plus button is presses
func _on_create_new_pressed() -> void:
	_object_picker_main.hide()
	_create_component.show()


## Called when the cancel button is pressed in the create component panel
func _on_create_component_canceled() -> void:
	_object_picker_main.show()
	_create_component.hide()


## Called when a component has been added to the engine from the create component panel
func _on_create_component_component_created(component: EngineComponent) -> void:
	_object_picker_main.show()
	_create_component.hide()
	
	_tree.deselect_all()
	_tree.set_selected(_component_refs.keys()[_component_refs.values().find(component)], 0)


## Called when the select button is pressed
func _on_select_pressed() -> void:
	selection_confirmed.emit(selected_items)


## Called when the cancel button is pressed
func _on_cancel_pressed() -> void:
	selection_canceled.emit()

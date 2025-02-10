# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name CreateComponent extends PanelContainer
## UI component to create or selecting a new component class


## Emitted when the create button is pressed in class mode
signal class_confirmed(classname: String)

## Emitted once the created component is added to the client engine
signal component_created(component: EngineComponent)

## Emitted when the cancel button is pressed
signal canceled()


## The Tree node to show all classes
@export var _class_tree: Tree = null

## The create button
@export var _create_button: Button = null

## Selection Label
@export var _selection_label: Label


## Mode enum, Class = Select and return a class name. Component = Create and return a new component of the given class
enum Mode {Class, Component}

## The current mode
var _mode: Mode = Mode.Class

## Current selected class
var _current_class: String = ""

## Display filter
var _direct_filter: String = ""
var _indirect_filter: Array = []


func _ready() -> void:
	ClassList.custom_classes_loaded.connect(_reload)
	_reload()


## Filters the class tree to only show classes of the given type
func set_class_filter(classname: String) -> void:
	if classname:
		_direct_filter = classname
		_indirect_filter = ClassList.get_class_inheritance_tree(classname)
		while _indirect_filter.has(classname):
			_indirect_filter.erase(classname)
	
	else:
		_direct_filter = ""
		_indirect_filter.clear()
	
	_reload()


## Sets the creation mode
func set_mode(mode: Mode) -> void:
	_mode = mode


## Deselects all items in the tree
func deselect_all() -> void:
	_class_tree.deselect_all()
	_create_button.disabled = true
	_selection_label.text = ""
	_current_class = ""


## Reloads the class tree
func _reload() -> void:
	var class_tree: Dictionary = ClassList.get_global_class_tree()
	_class_tree.clear()
	
	for classname: String in class_tree:
		_traverse_class_tree(classname, class_tree[classname], _class_tree.create_item(), [classname])


## Loop through each (nested) key pair and render it to the tree
func _traverse_class_tree(classname: String, value: Variant, previous_node: TreeItem, current_position: Array) -> void:
	if ClassList.is_class_hidden(classname):
		return
	
	var is_indirect: bool = _indirect_filter.has(classname)
	
	if _direct_filter:
		if not current_position.has(_direct_filter) and not is_indirect:
			return
		if is_indirect and value is Script:
			return
	
	var class_node: TreeItem = _class_tree.create_item(previous_node)
	class_node.set_text(0, classname)
	class_node.set_icon(0, Interface.get_class_icon(classname))
	
	if value is Dictionary:
		class_node.set_custom_color(0, Color.WEB_GRAY)
		
		for child_class in value.keys():
			current_position.push_back(child_class)
			_traverse_class_tree(child_class, value[child_class], class_node, current_position)
			current_position.pop_back()


## Called when the create button is pressed, or when an item is double clicked
func _create() -> void:
	if _current_class:
		if _mode == Mode.Class:
			class_confirmed.emit(_current_class)
		
		else:
			Core.create_component(_current_class).then(func (new_component: EngineComponent):
				component_created.emit(new_component)
			)
			deselect_all()


## Called when an item is selected in the tree
func _on_class_tree_item_selected() -> void:
	var selected: TreeItem = _class_tree.get_selected()
	
	if not selected.get_child_count():
		_current_class = selected.get_text(0)
		_selection_label.text = _current_class
		
		_create_button.disabled = false
	else:
		_selection_label.text = ""
		_create_button.disabled = true


## Called when the cancel button is pressed
func _on_cancel_pressed() -> void:
	canceled.emit()

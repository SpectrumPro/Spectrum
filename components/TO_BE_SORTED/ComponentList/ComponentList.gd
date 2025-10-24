# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name ComponentList extends PanelContainer
## Allow for choosing method on object to call by buttons sliders


## Emitted when a component is selected
signal selected(component: EngineComponent)


## The tree node for components
@export var _component_tree: Tree

## Classname filter for components to display
@export var component_filter: String


## RefMap for class parent nodes in the tree
var _class_parents: RefMap = RefMap.new()

## RefMap for component items
var _component_items: RefMap = RefMap.new()

## Root tree item
var _tree_root: TreeItem


func _ready() -> void:
	ComponentDB.request_class_callback(component_filter, _component_callback)
	
	_tree_root = _component_tree.create_item()
	_component_callback(ComponentDB.get_components_by_classname(component_filter), [])


## Gets the selected component, or null
func get_selected() -> EngineComponent:
	return _component_items.right(_component_tree.get_selected())


## Class callback for ComponentDB
func _component_callback(added: Array, removed: Array):
	for component: EngineComponent in added:
		var parent: TreeItem = _tree_root
		
		for classname: String in component.class_tree:
			if not ClassList.does_class_inherit(classname, component_filter) or classname == component_filter:
				continue
			
			if classname not in _class_parents.get_left():
				parent = parent.create_child()
				
				parent.set_text(0, classname)
				parent.set_icon(0, UIDB.get_class_icon(classname))
				
				_class_parents.map(classname, parent)
			
			else:
				parent = _class_parents.left(classname)
		
		var component_item: TreeItem = parent.create_child()
		
		component_item.set_text(0, component.get_name())
		component_item.set_icon(0, UIDB.get_class_icon(component.self_class_name))
		component.name_changed.connect(func (new_name: String): component_item.set_text(0, new_name))
		
		_component_items.map(component, component_item)
	
	for component: EngineComponent in removed:
		var component_item: TreeItem = _component_items.left(component)
		var parent: TreeItem = component_item.get_parent()
		
		if component_item == _component_tree.get_selected():
			selected.emit(null)
		
		parent.remove_child(component_item)
		
		while parent:
			var grandparent := parent.get_parent()
			if not parent.get_children() and grandparent:
				grandparent.remove_child(parent)
				parent = grandparent
			else:
				break


## Called when an item is selected in the tree
func _on_component_tree_item_selected() -> void:
	var selected_item: TreeItem = _component_tree.get_selected()
	
	if selected_item in _component_items.get_right():
		selected.emit(_component_items.right(selected_item))
	
	else:
		selected.emit(null)

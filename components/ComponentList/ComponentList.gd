# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name ComponentList extends PanelContainer
## Allow for choosing method on object to call by buttons sliders


## The tree node for components
@export var _component_tree: Tree

## Classname filter for components to display
@export var component_filter: String


## RefMap for class parent nodes in the tree
var _class_parents: RefMap = RefMap.new()

## Root tree item
var _tree_root: TreeItem


func _ready() -> void:
	ComponentDB.request_class_callback(component_filter, _component_callback)
	
	_tree_root = _component_tree.create_item()
	_component_callback(ComponentDB.get_components_by_classname(component_filter), [])


## Class callback for ComponentDB
func _component_callback(added: Array, removed: Array):
	for component: EngineComponent in added:
		var parent: TreeItem = _tree_root
		
		for classname: String in component.class_tree:
			if classname not in _class_parents.get_left():
				parent = parent.create_child()
				parent.set_text(0, classname)
				_class_parents.map(classname, parent)
			
			else:
				parent = _class_parents.left(classname)
		
		var component_item: TreeItem = parent.create_child()
		component_item.set_text(0, component.get_name())
		component.name_changed.connect(func (new_name: String): component_item.set_text(0, new_name))

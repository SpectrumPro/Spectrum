# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name SearchableClassTree extends UIComponent
## A tree containing a list of classes that are searchable


## Emitted when the SearchMode is changed
signal search_mode_changed(mode: SearchMode)

## Emitted when an object is selected
signal object_selected(object: Object)


## Enum for SearchMode
enum SearchMode {
	CLASS,		## Searching for classes
	OBJECT		## Searching for objects with a given class
}


## The InheritanceTree
@export var inheritance_tree: Tree

## The SearchableTree
@export var searchable_tree: Tree

## The ObjectTree
@export var object_tree: Tree

## Min size of the second tree column
@export var column_min_size: int = 100


## The ClassTreeConfig
var _config: ClassTreeConfig

## RefMap for TreeItem: "ClassName"
var _class_items: RefMap = RefMap.new()

## RefMap for TreeItem: Object
var _object_items: RefMap = RefMap.new()

## Current search mode
var _search_mode: SearchMode = SearchMode.CLASS

## The classname of SearchMode.OBJECT
var _search_mode_object_class: String = ""

## The current search text
var _search_text: String = ""


## Init
func _init() -> void:
	super._init()
	_set_class_name("SeachableClassTreee")


## Ready
func _ready() -> void:
	[inheritance_tree, searchable_tree, object_tree].map(func (tree: Tree):
		tree.set_column_expand(1, false)
		tree.set_column_custom_minimum_width(1, column_min_size)
	)


## Gets the selected object class for SearchMode.OBJECT
func get_object_class() -> String:
	return _search_mode_object_class


## Focuses the current Tree
func focus() -> void:
	_get_active_tree().grab_focus()


## Selectes the next item in the tree
func select_next() -> void:
	var tree: Tree = _get_active_tree()
	var current: TreeItem = tree.get_selected()
	var next_item: TreeItem = current.get_next_visible(true) if current else tree.get_root().get_child(0)
	
	if next_item:
		next_item.select(0)
	
	tree.ensure_cursor_is_visible()


## Selectes the next item in the tree
func select_prev() -> void:
	var tree: Tree = _get_active_tree()
	var current: TreeItem = tree.get_selected()
	var next_item: TreeItem = current.get_prev_visible(true) if current else tree.get_root().get_child(0)
	
	if next_item:
		next_item.select(0)
	
	tree.ensure_cursor_is_visible()


## Activates the selected TreeItem
func activate_selected() -> void:
	var tree: Tree = _get_active_tree()
	var selected: TreeItem = tree.get_selected()
	
	if not selected or selected == tree.get_root():
		return
	
	match _search_mode:
		SearchMode.CLASS:
			search_mode_object(selected.get_text(0))
			
		SearchMode.OBJECT:
			object_selected.emit(_object_items.left(selected))


## Loads a ClassTreeConfig
func load_config(p_config: ClassTreeConfig) -> void:
	_config = p_config
	
	inheritance_tree.clear()
	searchable_tree.clear()
	
	inheritance_tree.create_item()
	searchable_tree.create_item()
	
	_climb_branch.call(inheritance_tree.get_root(), p_config.get_class_tree(), p_config.get_class_tree().keys()[0])


## Sets the search mode to SearchMode.CLASS
func search_mode_class() -> void:
	_search_mode = SearchMode.CLASS
	
	search_for("")
	search_mode_changed.emit(_search_mode)


## Sets the search mode to SearchMode.OBJECT
func search_mode_object(p_classname: String) -> void:
	_search_mode = SearchMode.OBJECT
	_search_mode_object_class = p_classname
	
	object_tree.clear()
	object_tree.create_item()
	_object_items.clear()
	
	for object: Object in _config.get_objects_by_classname(p_classname):
		var item: TreeItem = object_tree.create_item()
		var classname: String = _config.get_object_classname(object)
		
		item.set_text(0, _config.get_object_name(object))
		item.set_icon(0, UIDB.get_class_icon(classname))
		
		item.set_custom_color(1, Color(0x919191ff))
		item.set_text(1, "Use")
		
		_object_items.map(item, object)
	
	search_for("")
	search_mode_changed.emit(_search_mode)


## Searches for the given text
func search_for(p_text: String) -> void:
	var items_to_display: Array[Dictionary]
	var search_string: String = p_text.to_lower()
	var search_tree: Tree = null
	
	object_tree.hide()
	searchable_tree.hide()
	inheritance_tree.hide()
	
	match _search_mode:
		SearchMode.CLASS:
			if not p_text:
				inheritance_tree.show()
				return
			
			searchable_tree.show()
			search_tree = searchable_tree
			
			for classname: String in _class_items.get_right():
				items_to_display.append({
					"item_name": classname,
					"similarity": classname.similarity(search_string) if p_text else 0.0,
					"tree_item": _class_items.right(classname)
				})
		
		SearchMode.OBJECT:
			object_tree.show()
			search_tree = object_tree
			
			for object: Object in _object_items.get_right():
				var object_name: String = _config.get_object_name(object)
				items_to_display.append({
					"item_name": object_name,
					"similarity": object_name.similarity(search_string) if p_text else 0.0,
					"tree_item": _object_items.right(object)
				})
	
	items_to_display.sort_custom(func (p_a: Dictionary, p_b: Dictionary) -> bool:
		if search_string and len(search_string) < 3:
			return (p_a.item_name as String).to_lower().begins_with(search_string[0])
		elif search_string:
			return p_a.similarity > p_b.similarity
		else:
			return (p_a.item_name as String).naturalnocasecmp_to(p_b.item_name)
	)
	items_to_display.reverse()
	
	for item: Dictionary in items_to_display:
		item.tree_item.move_before(search_tree.get_root().get_child(0))
	
	if search_tree.get_root().get_child_count():
		search_tree.get_root().get_child(0).select(0)
		search_tree.ensure_cursor_is_visible()
	
	_search_text = search_string


## Climbs a branch on the class tree
func _climb_branch(p_tree_branch: TreeItem, p_data_branch: Dictionary, p_previous_classname: String) -> void:
	for classname: String in p_data_branch.keys():
		if _config.is_class_hidden(classname):
			continue
		
		var value: Variant = p_data_branch[classname]
		var new_branch = p_tree_branch.create_child()
		
		new_branch.set_text(0, classname)
		new_branch.set_icon(0, UIDB.get_class_icon(classname))
		
		new_branch.set_custom_color(1, Color(0x919191ff))
		new_branch.set_text(1, "Enter")
		
		if value is Dictionary:
			_climb_branch.call(new_branch, value, classname)
		
		elif value is Script:
			var flat_item: TreeItem = searchable_tree.create_item()
			
			flat_item.set_text(0, classname)
			flat_item.set_icon(0, UIDB.get_class_icon(classname))
			
			flat_item.set_custom_color(1, Color(0x919191ff))
			flat_item.set_text(1, p_previous_classname)
			
			_class_items.map(flat_item, classname)


## Gets the active tree
func _get_active_tree() -> Tree:
	match _search_mode:
		SearchMode.CLASS when not _search_text:
			return inheritance_tree
		
		SearchMode.CLASS when _search_text:
			return searchable_tree
		
		_:
			return object_tree

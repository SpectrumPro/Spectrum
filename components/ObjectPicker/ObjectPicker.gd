# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## A view to select items


#region Public Members
## Emitted when an item is selected
signal item_selected(key, value)

## Emitted when an item is deselected
signal item_deselected(key, value)

## Emitted when the close button is pressed
signal closed
#endregion


## Wheather to unpress the button after it gets pressed
var _toggle_mode: bool = false

## Stores object refernces as {object: button_node}
var _object_refs: Dictionary = {}

#region Public Methods

## Load objects from a dictnary, where the key is the name, and the value being the object to be selected.
## By default the key is used as the display name, to use a member from the object, put the name of the member in name_member
func load_objects(objects: Dictionary, tab_name: String, name_member: String = "") -> void:
	var grid_node: ScrollContainer = load("res://components/ObjectPicker/Grid.tscn").instantiate()
	
	for object_key: String in objects:
		var new_node: Button = load("res://components/ObjectPicker/Button.tscn").instantiate()
		
		new_node.toggle_mode = true
		new_node.toggled.connect(func (state: bool):
			if state:
				item_selected.emit(object_key, objects[object_key])
				if not _toggle_mode:
					new_node.set_pressed_no_signal(false)
			else:
				item_deselected.emit(object_key, objects[object_key])
		)
		
		_object_refs[objects[object_key]] = new_node
		
		if name_member:
			new_node.get_node("Label").text = objects[object_key].get(name_member)
		else:
			new_node.get_node("Label").text = object_key.capitalize()
		
		grid_node.get_node("Grid").add_child(new_node)
	
	grid_node.name = tab_name
	
	if $ObjectPicker.get_node_or_null(tab_name):
		var node_to_delete: Control = $ObjectPicker.get_node(tab_name)
		$ObjectPicker.remove_child(node_to_delete)
		node_to_delete.queue_free()
	
	$ObjectPicker.add_child(grid_node)


## Sets a filter on this object picker, will dissable any tab not in this list
func set_filter(filter: Array[String]) -> void:
	var tab_count: int = $ObjectPicker.get_tab_count()
	
	for idx: int in tab_count:
		var is_disabled: bool = false if $ObjectPicker.get_tab_control(idx).name in filter else true
		
		$ObjectPicker.set_tab_disabled(idx, is_disabled)
		if not is_disabled:
			$ObjectPicker.current_tab = idx


func set_multi_select(state: bool) -> void:
	_toggle_mode = state
	
	for tab: Control in $ObjectPicker.get_children():
		for button: Button in tab.get_node("Grid").get_children():
			button.button_pressed = false


## Sets the selected buttons in the picker, using the objects they are linked to. only works if toggle mode is enabled
func set_selected(selection: Array) -> void:
	if _toggle_mode:
		for object: Variant in selection:
			if _object_refs.has(object):
				(_object_refs[object] as Button).set_pressed_no_signal(true)

#endregion


func _on_close_requested() -> void:
	get_parent().hide()
	closed.emit()

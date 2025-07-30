# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIDesk extends UIPanel
## A customisable UI layout


## Emitted when the snapping distance is changed. Will be Vector2.ZERO when snapping is disabled.
signal snapping_distance_changed(snapping_distance: Vector2)


## Array of buttons to disable when no panel is selected
@export var disable_on_deselect: Array[Button]

## The SelectBox node
@export var _select_box: SelectBox

## The container used for holding the panels
@export var _container_node: DrawGrid


## Whether snapping is enabled in this desk
var _snapping_enabled: bool = true

## The snapping distance of desk items in px
var _snapping_distance: Vector2 = Vector2(20, 20)

## The selected panels
var _selected_items: Array[UIDeskItemContainer] = []

## The position of the most recently deleted item, so a new one can appear in its place
var _just_deleted_pos: Vector2 = Vector2.ZERO

## The size of the most recently deleted panel
var _just_deleted_size: Vector2 = Vector2(100, 100)


## Init
func _init() -> void:
	_set_class_name("UIDesk")


## Selects all the panels in this desk
func select_all() -> void:
	for item: Control in _container_node.get_children():
		select_item(item)


## Deselects all the panels in this desk
func select_none() -> void:
	for item: Control in _selected_items.duplicate():
		deselect_item(item)


## Selects an individual panel
func select_item(p_item: Control) -> void:
	p_item.set_selected(true)
	
	if not _selected_items:
		enable_button_array(disable_on_deselect)
	
	if p_item not in _selected_items:
		_selected_items.append(p_item)


## Deselects an individual panel
func deselect_item(p_item: Control) -> void:
	p_item.set_selected(false)
	_selected_items.erase(p_item)
	
	if not _selected_items:
		disable_button_array(disable_on_deselect)


## Sets whether snapping is enabled in this desk
func set_snapping_enabled(p_enabled: bool) -> void:
	_snapping_enabled = p_enabled
	_container_node.show_grid = _snapping_enabled
	snapping_distance_changed.emit(_snapping_distance if _snapping_enabled else Vector2.ZERO)


## Sets the snapping distance of this desk
func set_snapping_distance(p_distance: Vector2) -> void:
	_snapping_distance = p_distance
	_container_node.grid_size = _snapping_distance * 2
	snapping_distance_changed.emit(_snapping_distance)


## Adds a new panel to this desk
func add_panel(p_panel: UIPanel, p_position: Vector2 = _just_deleted_pos, p_size: Vector2 = _just_deleted_size) -> UIDeskItemContainer:
	var new_node: UIDeskItemContainer = preload("uid://cebqk3au5iwx0").instantiate()
	new_node.set_edit_mode(true)

	# Connect signals to the item container
	edit_mode_toggled.connect(new_node.set_edit_mode)
	snapping_distance_changed.connect(new_node.set_snapping_distance)

	new_node.clicked.connect(_on_item_clicked.bind(new_node))
	new_node.right_clicked.connect(open_settings.bind(new_node))

	# Add the new panel
	new_node.set_panel(p_panel)
	new_node.set_edit_mode(get_edit_mode())

	new_node.position = p_position
	new_node.size = p_size
	_container_node.add_child(new_node, true)
	
	new_node.hide()
	Interface.show_and_fade(new_node)
	return new_node


## Opens the settings on the given node or selected item
func open_settings(p_node: UIDeskItemContainer = null) -> void:
	if _selected_items or p_node:
		var panel: UIPanel = _selected_items[0].get_panel() if not p_node else p_node.get_panel()
		panel.show_settings()


## Returns a dictionary containing all panels, their positions, sizes, and settings
func _save() -> Dictionary:
	var items: Array = []

	for desk_item_container: UIDeskItemContainer in _container_node.get_children():
		items.append(desk_item_container.save())

	return {
		"items": items,
	}


## Loads all items in this desk from a saved dictionary
func _load(p_saved_data: Dictionary) -> void:
	if p_saved_data.get("items") is Array:
		for p_panel_data: Dictionary in p_saved_data.items:
			if p_panel_data.get("type", "") in Interface.panels:
				var new_panel: Control = Interface.panels[p_panel_data.type].instantiate()
				
				var new_position: Vector2 = Vector2.ZERO
				if len(p_panel_data.get("position", [])) == 2:
					new_position = Vector2(int(p_panel_data.position[0]), int(p_panel_data.position[1]))
				
				var new_size: Vector2 = Vector2(100, 100)
				if len(p_panel_data.get("size", [])) == 2:
					new_size = Vector2(int(p_panel_data.size[0]), int(p_panel_data.size[1]))
				
				add_panel(new_panel, new_position, new_size).load.call_deferred(p_panel_data)


## Override this function to change state when edit mode is toggled
func _edit_mode_toggled(state: bool) -> void:
	_container_node.show_point = state


## Called when the add button is pressed
func _on_add_pressed() -> void:
	Interface.prompt_panel_picker(self).then(func (p_panel_class: String):
		add_panel(UIDB.instance_panel(p_panel_class))
	)


## Removes the selected items from this desk
func _on_delete_pressed() -> void:
	for item: UIDeskItemContainer in _selected_items.duplicate():
		deselect_item(item)
		
		_just_deleted_pos = item.position
		_just_deleted_size = item.size
		
		Interface.fade_and_hide(item, func ():
			item.queue_free()
		)


## Called when the edit button is pressed
func _on_edit_pressed() -> void:
	open_settings()


## Called when the copy button is pressed
func _on_copy_pressed() -> void:
	var nodes_to_copy: Array = _selected_items.duplicate()
	select_none()
	
	for panel_container: Control in nodes_to_copy:
		select_item(add_panel(
			panel_container.get_panel().duplicate(),
			panel_container.position,
			panel_container.size
		))


## Called when the value in the snapping distance box is changed
func _on_snapping_distance_value_changed(p_value: float) -> void:
	set_snapping_distance(Vector2(p_value, p_value))


## Moves the selected items up so they appear on top
func _on_move_up_pressed() -> void:
	for item in _selected_items:
		_container_node.move_child(item, item.get_index() + 1)


## Moves the selected items down so they appear underneath
func _on_move_down_pressed() -> void:
	for item in _selected_items:
		_container_node.move_child(item, clamp(item.get_index() - 1, 0, INF))


## Called when a panel is clicked in edit mode
func _on_item_clicked(p_item: Control) -> void:
	if not Input.is_key_label_pressed(KEY_SHIFT):
		select_none()
	
	select_item(p_item)


## Called when the container receives an input event. Handles selection and object picker display.
func _on_container_gui_input(p_event: InputEvent) -> void:
	if p_event is InputEventMouseButton:
		if p_event.is_pressed() and _edit_mode:
			select_none()
		
		if p_event.button_index == MOUSE_BUTTON_RIGHT and p_event.is_pressed() and _edit_mode:
			Interface.prompt_panel_picker(self).then(func (p_panel_class: String):
				add_panel(UIDB.instance_panel(p_panel_class))
			)


## Called when the selection is released in the select box
func _on_select_box_released() -> void:
	var rect: Rect2 = _select_box.get_selection()
	
	Interface.prompt_panel_picker(self).then(func (p_panel_class: String):
		add_panel(UIDB.instance_panel(p_panel_class), rect.position.snapped(_snapping_distance), rect.size.snapped(_snapping_distance))
	)

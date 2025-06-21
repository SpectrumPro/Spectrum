# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UIDesk extends UIPanel
## A customisable ui layout


## Emitted when the snapping distance is changed, will be 0 when snapping is dissabled
signal snapping_distance_changed(snapping_distance: Vector2)


## Whether snapping is enabled in this desk
var snapping_enabled: bool = true : set = set_snapping_enabled

## The snapping distance of desk items in px
var snapping_distance: Vector2 = Vector2(20, 20) : set = set_snapping_distance


#region Private Members
## The container used for holding the panels
@onready var _container_node: Control = $VBoxContainer/PanelContainer2/Container

## The selected panels
var _selected_items: Array[Control] = []

## The position and size of the most recenelt deleted item, so if you add a new item straight away, it will appre where the one that was deleted was
var _just_deleted_pos: Vector2 = Vector2.ZERO
var _just_deleted_size: Vector2 = Vector2(100, 100)

#endregion



#region Public Methods

## Select all the panels in this desk
func select_all() -> void:
	for item: Control in _container_node.get_children():
		select_item(item)


## Deselects all the panels in this desk
func select_none() -> void:
	for item: Control in _selected_items.duplicate():
		deselect_item(item)


## Selects an individual panel
func select_item(item: Control) -> void:
	item.set_selected(true)
	
	if item not in _selected_items:
		_selected_items.append(item)


## Deselects an individual panel
func deselect_item(item: Control) -> void:
	item.set_selected(false)
	_selected_items.erase(item)


## Sets whether snapping is enabled in this desk
func set_snapping_enabled(p_snapping_enabled) -> void:
	snapping_enabled = p_snapping_enabled
	
	_container_node.show_grid = snapping_enabled
	
	snapping_distance_changed.emit(snapping_distance if snapping_enabled else Vector2.ZERO)


## Sets the snapping distance of this desk
func set_snapping_distance(p_snapping_distance: Vector2) -> void:
	snapping_distance = p_snapping_distance
	_container_node.grid_size = snapping_distance * 2
	
	snapping_distance_changed.emit(snapping_distance)


## Adds a new panel to this desk
func add_panel(panel: Control, new_position: Vector2 = _just_deleted_pos, new_size: Vector2 = _just_deleted_size, container_name: String = "") -> DeskItemContainer:
	var new_node: DeskItemContainer = Interface.components.DeskItemContainer.instantiate()
	new_node.set_edit_mode(true)
	
	## Connect signals to the item container
	edit_mode_toggled.connect(new_node.set_edit_mode)
	snapping_distance_changed.connect(new_node.set_snapping_distance)
	
	new_node.clicked.connect(_on_item_clicked.bind(new_node))
	new_node.right_clicked.connect(open_settings.bind(new_node))
	
	## Add the new panel that was selected in the object picker
	new_node.set_panel(panel)
	new_node.set_edit_mode(get_edit_mode())
	
	new_node.position = new_position
	new_node.size = new_size
	
	if container_name:
		new_node.name = container_name
	_container_node.add_child(new_node, true)
	
	return new_node


## Opens the settings on the given nodes
func open_settings(node: DeskItemContainer = null) -> void:
	if _selected_items or node:
		var panel: UIPanel = _selected_items[0].get_panel() if not node else node.get_panel()
		
		panel.show_settings()


## Returns a dictionary containing all the panels, there position, sizes, and setting for this desk
func save() -> Dictionary:
	var items: Array = []
	
	for desk_item_container: DeskItemContainer in _container_node.get_children():
		items.append(desk_item_container.save())
	
	return {
		"items": items,
	}


## Loads all the items in this desk form thoes returned by save()
func load(saved_data: Dictionary) -> void:
	
	if saved_data.get("items") is Array:
		for saved_panel: Dictionary in saved_data.items:
			if saved_panel.get("type", "") in Interface.panels:
				var new_panel: Control = Interface.panels[saved_panel.type].instantiate()
				
				var new_position: Vector2 = Vector2.ZERO
				if len(saved_panel.get("position", [])) == 2:
					new_position = Vector2(int(saved_panel.position[0]), int(saved_panel.position[1]))
				
				var new_size: Vector2 = Vector2(100, 100)
				if len(saved_panel.get("size", [])) == 2:
					new_size = Vector2(int(saved_panel.size[0]), int(saved_panel.size[1]))
				
				add_panel(new_panel, new_position, new_size).load.call_deferred(saved_panel)

#endregion


#region Ui Signals

## Called when the add button is pressed
func _on_add_pressed() -> void:
	Interface.show_panel_picker().then(func (panel: PackedScene):
		add_panel(panel.instantiate())
	)


## Removes the selected items from this desk
func _on_delete_pressed() -> void:
	for item: DeskItemContainer in _selected_items.duplicate():
		deselect_item(item)
		
		_just_deleted_pos = item.position
		_just_deleted_size = item.size
		
		item.queue_free()


## Called when the edit button is pressed
func _on_edit_pressed() -> void:
	open_settings()


## Called when the copy button is pressed
func _on_copy_pressed() -> void:
	var nodes_to_copy: Array = _selected_items.duplicate()
	select_none()
	
	for panel_container: Control in nodes_to_copy:
		select_item(add_panel(panel_container.get_panel().duplicate(), panel_container.position, panel_container.size))


## Called when the value in the snapping distance box is changed
func _on_snapping_distance_value_changed(v: float) -> void:
	set_snapping_distance(Vector2(v, v))


## Moves the selected items up so they apper on top
func _on_move_up_pressed() -> void:
	for item in _selected_items:
		_container_node.move_child(item, item.get_index() + 1)


## Moves the selected items down to they apper underneath
func _on_move_down_pressed() -> void:
	for item in _selected_items:
		_container_node.move_child(item, clamp(item.get_index() - 1, 0, INF))


## Called when a panel is clicked in edit mode
func _on_item_clicked(item: Control) -> void:
	if not Input.is_key_label_pressed(KEY_SHIFT):
		select_none()
	
	select_item(item)


## Called when the container has a input event, checks to see if it is a mouse click, if so will show or hide the object picker
func _on_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and _edit_mode:
			select_none()
		
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() and _edit_mode:
			Interface.show_panel_picker().then(func (panel: PackedScene):
				add_panel(panel.instantiate())
			)
				
#endregion

# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## A customisable ui layout


#region Public Members
## Emitted when edit mode is toggled
signal edit_mode_toggled(edit_mode: bool)

## Emitted when the snapping distance is changed, will be 0 when snapping is dissabled
signal snapping_distance_changed(snapping_distance: Vector2)

## Whether or not to allow panels to be edited, deleted or added
var edit_mode: bool = true : set = set_edit_mode

## Whether snapping is enabled in this desk
var snapping_enabled: bool = true : set = set_snapping_enabled

## The snapping distance of desk items in px
var snapping_distance: Vector2 = Vector2(20, 20) : set = set_snapping_distance
#endregion


#region Private Members
## The container used for holding the panels
@onready var _container_node: Control = $VBoxContainer/PanelContainer2/Container

## The selected panels
var _selected_items: Array[Control] = []
#endregion


## Called when this desk is ready
func _ready() -> void:
	$ObjectPicker.load_objects(Interface.panels, "Panels")


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


## Called when the edit mode toggle is pressed
func set_edit_mode(p_edit_mode: bool) -> void:
	edit_mode = p_edit_mode
	$VBoxContainer/PanelContainer/HBoxContainer/EditMode.set_pressed_no_signal(edit_mode)
	
	edit_mode_toggled.emit(edit_mode)


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
#endregion



#region Ui Signals

## Called when an object is selected in the object picker, used to add new objects
func _on_object_picker_item_selected(key, value):
	$ObjectPicker.hide()
	
	var new_node: Control = Interface.components.DeskItemContainer.instantiate()
	new_node.set_edit_mode(true)
	
	## Connect signals to the item container
	edit_mode_toggled.connect(new_node.set_edit_mode)
	snapping_distance_changed.connect(new_node.set_snapping_distance)
	new_node.clicked.connect(_on_item_clicked.bind(new_node))
	
	## Add the new panel that was selected in the object picker
	new_node.set_child(value.instantiate())
	_container_node.add_child(new_node)


## Called when the add button is pressed
func _on_add_pressed() -> void:
	$ObjectPicker.show()
	set_edit_mode(true)


## Removes the selected items from this desk
func _on_delete_pressed() -> void:
	for item in _selected_items.duplicate():
		deselect_item(item)
		item.queue_free()


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
		if event.is_pressed():
			select_none()
		
		if $ObjectPicker.visible and event.button_index == MOUSE_BUTTON_LEFT:
			$ObjectPicker.hide()
		
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() and edit_mode:
			$ObjectPicker.show()
		

#endregion



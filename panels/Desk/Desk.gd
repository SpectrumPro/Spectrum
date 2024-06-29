# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name Desk extends PanelContainer
## A customisable ui layout


#region Public Members
## Emitted when edit mode is toggled
signal edit_mode_toggled(edit_mode: bool)

## Emitted when the snapping distance is changed, will be 0 when snapping is dissabled
signal snapping_distance_changed(snapping_distance: Vector2)

## Whether or not to allow panels to be edited, deleted or added
var edit_mode: bool = false : set = set_edit_mode

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

## Used to check if we opened the object picker, not another script
var _object_picker_opened_here: bool = false


func _ready() -> void:
	edit_mode = false


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
	
	for node: Control in $VBoxContainer/PanelContainer/HBoxContainer.get_children():
		if node is Button and not node is CheckButton:
			node.disabled = not edit_mode
			
		if node is SpinBox:
			node.editable = edit_mode
		
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


## Adds a new panel to this desk
func add_panel(panel: Control, new_position: Vector2 = Vector2.ZERO, new_size: Vector2 = Vector2(100, 100), container_name: String = "") -> Control:
	var new_node: Control = Interface.components.DeskItemContainer.instantiate()
	new_node.set_edit_mode(true)
	
	## Connect signals to the item container
	edit_mode_toggled.connect(new_node.set_edit_mode)
	snapping_distance_changed.connect(new_node.set_snapping_distance)
	
	new_node.clicked.connect(_on_item_clicked.bind(new_node))
	
	## Add the new panel that was selected in the object picker
	new_node.set_panel(panel)
	new_node.set_edit_mode(edit_mode)
	
	new_node.position = new_position
	new_node.size = new_size
	
	if container_name:
		new_node.name = container_name
	_container_node.add_child(new_node, true)
	
	return new_node


## Returns a dictionary containing all the panels, there position, sizes, and setting for this desk
func save() -> Dictionary:
	var items: Array = []
	
	for desk_item_container: Control in _container_node.get_children():
		
		var settings: Dictionary = {}
		var panel: Control = desk_item_container.get_panel()
		
		if  panel.get("save") is Callable:
			settings = panel.save()
		
		var script_name: String = panel.get_script().resource_path.get_file()
			
		items.append({
			"type": script_name.substr(0, script_name.rfind(".")),
			"position": [desk_item_container.position.x, desk_item_container.position.y],
			"size": [desk_item_container.size.x, desk_item_container.size.y],
			"settings": settings
		})
	
	return {
		"items": items,
	}


## Loads all the items in this desk form thoes returned by save()
func load(saved_data: Dictionary) -> void:
	
	if saved_data.has("items"):
		for saved_panel: Dictionary in saved_data.items:
			if saved_panel.get("type", "") in Interface.panels:
				var new_panel: Control = Interface.panels[saved_panel.type].instantiate()
				
				var new_position: Vector2 = Vector2.ZERO
				if len(saved_panel.get("position", [])) == 2:
					new_position = Vector2(int(saved_panel.position[0]), int(saved_panel.position[1]))
				
				var new_size: Vector2 = Vector2(100, 100)
				if len(saved_panel.get("size", [])) == 2:
					new_size = Vector2(int(saved_panel.size[0]), int(saved_panel.size[1]))
				
				add_panel(new_panel, new_position, new_size)
				
				if new_panel.get("load") is Callable:
					new_panel.load(saved_panel.get("settings", {}))
				
				
	
	#for container_name: String in saved_data:
		#if saved_data[container_name].get("type", "") in Interface.panel:
			#var panel: Control = Interface.panels[ saved_data[container_name].type]
			#var position: Vector2 = saved_data[container_name].get("position", Vector2.ZERO)
			#var size: Vector2 = saved_data[container_name].get("size", Vector2(100, 100))
			#
			#var new_desk_item_container: DeskItemContainer = add_panel(panel, position, size)
			#
			#new_desk_item_container.load(saved_data[container_name].get("settings", {}))
#endregion


#region Ui Signals

## Called when an object is selected in the object picker, used to add new objects
func _on_object_picker_item_selected(key, value):
	add_panel(value.instantiate())


## Called when the add button is pressed
func _on_add_pressed() -> void:
	Interface.show_object_picker(_on_object_picker_item_selected, ["Panels"])
	_object_picker_opened_here = true
	set_edit_mode(true)


## Removes the selected items from this desk
func _on_delete_pressed() -> void:
	for item in _selected_items.duplicate():
		deselect_item(item)
		item.queue_free()


## Called when the edit button is pressed
func _on_edit_pressed() -> void:
	if _selected_items:
		var panel: Control = _selected_items[0].get_panel()
		
		if "settings_node" in panel:
			$PanelSettingsContainer.set_node(panel.settings_node)
		
	else:
		$PanelSettingsContainer.remove_node()
	
	$PanelSettingsContainer.show()


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
		if event.is_pressed() and edit_mode:
			select_none()
		
		if event.button_index == MOUSE_BUTTON_LEFT and _object_picker_opened_here:
			Interface.hide_object_picker()
			_object_picker_opened_here = false
		
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() and edit_mode:
			Interface.show_object_picker(_on_object_picker_item_selected, ["Panels"])
			_object_picker_opened_here = false

#endregion

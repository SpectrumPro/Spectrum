# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
signal edit_mode_toggled(edit_mode: bool)

@export_node_path("Control") var container: NodePath

var edit_mode: bool = true

var selected_items: Array[Control] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ObjectPicker.load_objects(Interface.panels, "Panels")


func select_all() -> void:
	for item: Control in get_node(container).get_children():
		select_item(item)


func select_none() -> void:
	for item: Control in selected_items.duplicate():
		deselect_item(item)


func select_item(item: Control) -> void:
	item.set_selected(true)
	
	if item not in selected_items:
		selected_items.append(item)


func deselect_item(item: Control) -> void:
	item.set_selected(false)
	selected_items.erase(item)


func _on_object_picker_item_selected(key, value):
	$ObjectPicker.visible = false
	
	var new_node: Control = Interface.components.DeskItemContainer.instantiate()
	
	new_node.set_edit_mode(edit_mode)
	edit_mode_toggled.connect(new_node.set_edit_mode)
	new_node.clicked.connect(_on_item_clicked.bind(new_node))
	
	var child_node: Control = value.instantiate()
	new_node.add_child(child_node)
	new_node.move_child(child_node, 0)
	
	get_node(container).add_child(new_node)


func _on_add_pressed() -> void:
	$ObjectPicker.visible = true


func _on_edit_mode_toggled(toggled_on: bool) -> void:
	edit_mode = toggled_on
	edit_mode_toggled.emit(edit_mode)


func _on_item_clicked(item: Control) -> void:
	if not Input.is_key_label_pressed(KEY_SHIFT):
		select_none()
	
	select_item(item)


func _on_move_up_pressed() -> void:
	for item in selected_items:
		get_node(container).move_child(item, item.get_index() + 1)


func _on_move_down_pressed() -> void:
	for item in selected_items:
		get_node(container).move_child(item, clamp(item.get_index() - 1, 0, INF))


func _on_delete_pressed() -> void:
	for item in selected_items.duplicate():
		deselect_item(item)
		item.queue_free()


func _on_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		select_none()

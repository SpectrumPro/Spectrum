# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## Container for storing panels, allows them to be split in half, and allows access to there settings


var _parent_mode: bool = false :
	set(value):
		_parent_mode = value
		$Controls.hide()


func _ready() -> void:
	Interface.edit_mode_changed.connect(func (edit_mode: bool):
		$Controls.visible = edit_mode if not _parent_mode else false
	)


func set_panel(panel: Control) -> void:
	if get_node_or_null("Panel"):
		var old_panel: Control = $Panel
		
		remove_child(old_panel)
		old_panel.queue_free()
	
	panel.name = "Panel"

	add_child(panel)
	$Controls.move_to_front()


## Shows the controls
func show_controls() -> void:
	$Controls.visible = true


## Called when this container is resized, will check to see if it needs to rotate the controls so they fix in the view
func _update_controls() -> void:
	if size.x < $Controls/HBoxContainer.size.x + 20 and not _parent_mode:
		$Controls/HBoxContainer.hide()
		$Controls/VBoxContainer.show()
	elif not _parent_mode:
		$Controls/HBoxContainer.show()
		$Controls/VBoxContainer.hide()


func _new_container() -> Control:
	var new_container: Control = load("res://Components/PanelContainer/PanelContainer.tscn").instantiate()
	new_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	new_container.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	new_container.show_controls()
	
	return new_container


func _on_left_pressed() -> void:
	var new_container: HSplitContainer = HSplitContainer.new()
	var new_panel_container: Control = _new_container()
	var panel: Control = $Panel
	
	if get_node_or_null("Panel"):
		remove_child(panel)
		new_panel_container.set_panel(panel)
	
	new_container.add_child(new_panel_container)
	new_container.add_child(_new_container())
	
	add_child(new_container)
	
	_parent_mode = true


func _on_top_pressed() -> void:
	var new_container: VSplitContainer = VSplitContainer.new()
	var new_panel_container: Control = _new_container()
	var panel: Control = $Panel
	
	if get_node_or_null("Panel"):
		remove_child(panel)
		new_panel_container.set_panel(panel)
	
	new_container.add_child(new_panel_container)
	new_container.add_child(_new_container())
	
	add_child(new_container)
	
	_parent_mode = true


func _on_buttom_pressed() -> void:
	var new_container: VSplitContainer = VSplitContainer.new()
	var new_panel_container: Control = _new_container()
	var panel: Control = $Panel
	
	if get_node_or_null("Panel"):
		remove_child(panel)
		new_panel_container.set_panel(panel)
	
	new_container.add_child(_new_container())
	new_container.add_child(new_panel_container)
	
	add_child(new_container)
	
	_parent_mode = true


func _on_right_pressed() -> void:
	var new_container: HSplitContainer = HSplitContainer.new()
	var new_panel_container: Control = _new_container()
	var panel: Control = $Panel
	
	if get_node_or_null("Panel"):
		remove_child(panel)
		new_panel_container.set_panel(panel)
	
	new_container.add_child(_new_container())
	new_container.add_child(new_panel_container)
	
	add_child(new_container)
	
	_parent_mode = true


func _on_edit_pressed() -> void:
	Interface.show_object_picker(func (key: Variant, value: Variant):
		set_panel(value.instantiate())
	, ["Panels"])

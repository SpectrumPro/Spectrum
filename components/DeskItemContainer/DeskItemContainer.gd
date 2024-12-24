# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name DeskItemContainer extends PanelContainer
## Container for desk items


#region Public Members
## Emitted whem this desk item is clicked in edit mode
signal clicked

## Emitted whem this desk item is right clicked in edit mode
signal right_clicked

## The BG color of this desk item when it is selected
@export var selected_color: Color

## The BG color of this desk item when it is not selected
@export var normal_color: Color

## the snapping distance of this desk item
@export var snapping_distance: Vector2 = Vector2(20, 20) : set = set_snapping_distance
#endregion


#region Private Members
## The new position of this item, used during processing
@onready var _new_position: Vector2 = self.position

## The new size of this item, used during processing
@onready var _new_size: Vector2 = self.size

## The lable node that displays the position and size of this item
@onready var _label_node: Label = $Handles/PanelContainer/Label

## The panel node
var _panel: UIPanel = null
#endregion


func _ready() -> void:
	$Handles/Background.add_theme_stylebox_override("panel", $Handles/Background.get_theme_stylebox("panel").duplicate())
	
	_label_node.label_settings = _label_node.label_settings.duplicate()
	update_label()


#region Public Methods

## Shows and hides the position / size controls
func set_edit_mode(edit_mode: bool) -> void:
	$Handles.visible = edit_mode


## Sets the selection state of this item, changing the background color
func set_selected(is_selected: bool) -> void:
	$Handles/Background.get_theme_stylebox("panel").bg_color = selected_color if is_selected else normal_color


## Sets the snapping distance of this item
func set_snapping_distance(p_snapping_distance: Vector2) -> void:
	snapping_distance = p_snapping_distance


## Sets the panel node of this item
func set_panel(panel: UIPanel) -> void:
	if _panel:
		remove_child(_panel)
		
		_panel.request_move.disconnect(_on_panel_request_move)
		_panel.request_resize.disconnect(_on_panel_request_move)
	
	_panel = panel
	
	if panel:
		add_child(_panel)
		move_child(_panel, 0)
		
		_panel.request_move.connect(_on_panel_request_move)
		_panel.request_resize.connect(_on_panel_request_resize)
	

## Gets the panel node set with set_panel, otherwise null
func get_panel() -> Variant:
	return _panel


## Updates the lable to show the correct position and size
func update_label() -> void:
	if self.size > Vector2(180, 180):
		_label_node.text = "W:" + str(size.x) + " H:" + str(size.y) + "\nX:" + str(position.x) + " Y:" + str(position.y)
		_label_node.label_settings.font_size = 16
	else:
		_label_node.text = "W:" + str(size.x) + "\nH:" + str(size.y) + "\nX:" + str(position.x) + "\nY:" + str(position.y)
		_label_node.label_settings.font_size = 10


## Loads the settings for this node from the settings returned by save()
func save() -> Dictionary:
	var saved_data: Dictionary = {
		"type": "",
		"position": [position.x, position.y],
		"size": [size.x, size.y],
		"settings": {}
	}
	
	if _panel:
		var script_name: String = _panel.get_script().resource_path.get_file()
		print(script_name.substr(0, script_name.rfind(".")))
		saved_data.merge({
			"type": script_name.substr(0, script_name.rfind(".")),
			"settings": _panel.save()
		}, true)
		
	return saved_data 

## Loads the settings for this node from the settings returned by save()
func load(saved_data: Dictionary) -> void:
	if _panel:
		_panel.load(saved_data.get("settings", {}))

#endregion


#region Ui Signals

## Called when there is a input event on the background, checks if it is a mouse drag, if so it will move and snap this item
func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_new_position += event.relative
		_new_position = _new_position.abs()
		
		self.position = _new_position.snapped(snapping_distance)
		
		update_label()
		
	if event is InputEventMouseButton and event.is_released():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				clicked.emit()
			MOUSE_BUTTON_RIGHT:
				right_clicked.emit()


## Called when there is a input event on the size handle, checks if it is a mouse drag, if so it will scale and snap this item
func _on_br_handle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_new_size += event.relative
		_new_size = _new_size.abs()
		self.size = _new_size.snapped(snapping_distance)
		update_label()
	
	if event.is_pressed():
		clicked.emit()


## Called when the client UIPanel emits request_move
func _on_panel_request_move(by: Vector2) -> void:
	_new_position += by
	position = snapped(_new_position, snapping_distance)


## Called when the client UIPanel emits request_move
func _on_panel_request_resize(by: Vector2) -> void:
	if Input.is_key_pressed(KEY_SHIFT): by = by * 4
	_new_size += by
	size = snapped(_new_size, snapping_distance)

#endregion

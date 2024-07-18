# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

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
var _panel: Control = null
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
func set_panel(panel: Control) -> void:
	if _panel:
		remove_child(_panel)
	
	if panel:
		_panel = panel
		add_child(_panel)
		move_child(_panel, 0)
	else:
		_panel = null


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
func load(saved_data: Dictionary) -> void:
	if has_node("Panel") and $Panel.get("load") is Callable:
		$Panel.load(saved_data)

#endregion


#region Ui Signals

## Called when there is a input event on the background, checks if it is a mouse drag, if so it will move and snap this item
func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_new_position += event.relative
		_new_position = _new_position.clamp(Vector2.ZERO, get_parent().size - size)
		
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
		_new_size = _new_size.clamp(custom_minimum_size, Vector2.INF)
		self.size = _new_size.snapped(snapping_distance)
		update_label()
	
	if event.is_pressed():
		clicked.emit()

#endregion

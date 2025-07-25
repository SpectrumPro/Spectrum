# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name UICueSheet extends UIPanel
## UI panel for editing DataContainers


## The Table
@export var _tree: Tree

## The selection box
@export var _select_box: PanelContainer

## The ObjectPickerButton
@export var _object_picker_button: ObjectPickerButton

## The IntensityButton
@export var _intensity_button: IntensityButton

## The CueTriggerModeOption button
@export var _cue_trigger_option: PopupMenu

## The Go Button
@export var _go_button: Button

## The DeleteCue buton
@export var _delete_button: Button

## All of the transport control buttons
@export var _transport_control_buttons: Array[Button] = []

## Background color of the active cue
@export var _active_cue_bg_color: Color

## Amount of extra cues to scroll past to make sure they are visable
@export var _auto_scroll_padding: int = 1

## Drag deadzone in px
@export var _drag_deadzone: int = 20


## Enum for all columns types
enum Columns {IDX, QID, NAME, FADE_TIME, WAIT_TIME, TRIGGER_MODE, FIXTURES}


## Config for column
var _column_config: Dictionary[int, Array] = {
	Columns.IDX: ["IDX", false, 20],
	Columns.QID: ["QID", false, 100],
	Columns.NAME: ["Name", true, 400],
	Columns.FADE_TIME: ["Fade Time", true, 0],
	Columns.WAIT_TIME: ["Wait Time", true, 0],
	Columns.TRIGGER_MODE: ["Trigger Mode", true, 0],
	Columns.FIXTURES: ["Fixtures", true, 0],
}

## The selected Function
var _cue_list: CueList

## RefMap for Cue:TreeItem
var _cue_items: RefMap = RefMap.new(Cue, TreeItem)

## Stores an ordered of all TreeItems
var _items_ordered: Array[TreeItem]

## The latest selected cue
var _selected_cue: Cue

## All selected cues, and the columns they are selected in
var _selected_cues: Dictionary[Cue, Array]

## All selected columns
var _selected_columns: Array[int]

## The TreeItem of the active cue
var _active_cue_item: TreeItem

## The root tree item
var _root: TreeItem

## Dragging state
var _is_dragging: bool = false

## True if a drag about to start, but hadent passed the deadzone yet
var _pending_drag: bool = false

## Drag start point
var _drag_start_point: Vector2 = Vector2.ZERO

## Signals to connect to the container
var _cuelist_signal_connections: Dictionary[String, Callable] = {
	"cues_added": _add_cues,
	"cues_removed": _remove_cues,
	"cue_order_changed": _move_cue_to,
	"active_cue_changed": _set_active_cue,
	"active_state_changed": _on_active_state_changed,
	"delete_request": set_cue_list.bind(null)
}

## Signal connections for the cue
var _cue_signal_connections: Dictionary[String, Callable] = {
	"qid_changed": _on_cue_qid_changed,
	"name_changed": _on_cue_name_changed,
	"fade_time_changed": _on_cue_fade_time_changed,
	"pre_wait_time_changed": _on_cue_wait_time_changed,
	"trigger_mode_changed": _on_cue_trigger_mode_changed,
	"items_stored": _update_cue_fixture_count,
	"items_erased": _update_cue_fixture_count,
}


func _ready() -> void:
	_reset()
	
	for trigger_mode: String in Cue.TriggerMode.keys():
		_cue_trigger_option.add_item(trigger_mode.capitalize())


## Called when an Function is selected
func set_cue_list(p_cue_list: CueList) -> bool:
	if p_cue_list == _cue_list:
		return false
	
	_reset()
	Utils.disconnect_signals(_cuelist_signal_connections, _cue_list)
	
	_cue_list = p_cue_list
	_object_picker_button.set_object(_cue_list)
	_intensity_button.set_function(_cue_list)
	_go_button.set_disabled(true)
	
	if not _cue_list:
		disable_button_array(_transport_control_buttons)
		return false
	
	Utils.connect_signals(_cuelist_signal_connections, _cue_list)
	enable_button_array(_transport_control_buttons)
	
	_add_cues(_cue_list.get_cues())
	_set_active_cue(_cue_list.get_active_cue())
	return true


## Adds mutiple cues at once
func _add_cues(p_cues: Array) -> void:
	for cue: Variant in p_cues:
		if cue is Cue:
			_add_cue(cue)


## Adds a cue to the list
func _add_cue(p_cue: Cue) -> bool:
	if _cue_items.has_left(p_cue):
		return false
	
	var tree_item: TreeItem = _tree.create_item()
	
	tree_item.set_text(Columns.IDX, str(_cue_list.get_cue_position(p_cue)))
	tree_item.set_text(Columns.QID, p_cue.get_qid())
	tree_item.set_text(Columns.NAME, p_cue.get_name())
	tree_item.set_text(Columns.FADE_TIME, str(p_cue.get_fade_time()))
	tree_item.set_text(Columns.WAIT_TIME, str(p_cue.get_pre_wait()))
	tree_item.set_text(Columns.TRIGGER_MODE, Cue.TriggerMode.keys()[p_cue.get_trigger_mode()].capitalize())
	tree_item.set_text(Columns.FIXTURES, str(len(p_cue.get_fixtures())))
	
	Utils.connect_signals_with_bind(_cue_signal_connections, p_cue)
	_cue_items.map(p_cue, tree_item)
	_items_ordered.append(tree_item)
	return true


## Removes mutiple cues
func _remove_cues(p_cues: Array) -> void:
	for cue: Variant in p_cues:
		if cue is Cue:
			_remove_cue(cue)


## Removes a cue from the list
func _remove_cue(p_cue: Cue) -> bool:
	if not _cue_items.has_left(p_cue):
		return false
	
	var tree_item: TreeItem = _cue_items.left(p_cue)
	_items_ordered.erase(tree_item)
	tree_item.free()
	
	Utils.disconnect_signals_with_bind(_cue_signal_connections, p_cue)
	_cue_items.erase_left(p_cue)
	return true


## Moves the given cue to the given index
func _move_cue_to(p_cue: Cue, p_position: int) -> void:
	var reference_item: TreeItem = _items_ordered[p_position]
	var item_to_move: TreeItem = _cue_items.left(p_cue)
	var old_index: int = _items_ordered.find(item_to_move)
	
	if p_position < old_index:
		item_to_move.move_before(reference_item)
	else:
		item_to_move.move_after(reference_item)
	
	_items_ordered.remove_at(old_index)
	_items_ordered.insert(p_position, item_to_move)
	
	var i: int = 0
	
	for cue: Cue in _cue_list.get_cues():
		_cue_items.left(cue).set_text(Columns.IDX, str(i))
		i += 1


## Called when the active cue is changed
func _set_active_cue(p_cue: Cue) -> void:
	var tree_item: TreeItem = _cue_items.left(p_cue)
	
	if _active_cue_item:
		for column: int in Columns.values():
			_active_cue_item.set_custom_bg_color(column, Color.TRANSPARENT, false)
	
	_active_cue_item = tree_item
	
	if _active_cue_item:
		for column: int in Columns.values():
			_active_cue_item.set_custom_bg_color(column, _active_cue_bg_color, false)
	
		var child_id: int = tree_item.get_index() + _auto_scroll_padding if tree_item.get_index() else 0
		var max_length: int = len(_cue_items.get_left())
		
		if child_id > max_length:
			child_id = max_length
		
		_tree.scroll_to_item(_root.get_child(child_id))


## Called when the ActiveState is changed
func _on_active_state_changed(p_active_state: Function.ActiveState) -> void:
	if not p_active_state:
		_set_active_cue(null)


## Called when the QID is changed in a cue
func _on_cue_qid_changed(p_qid: String, p_cue: Cue) -> void:
	var tree_item: TreeItem = _cue_items.left(p_cue)
	tree_item.set_text(Columns.QID, p_qid)


## Called when a cue's name is changed
func _on_cue_name_changed(p_name: String, p_cue: Cue) -> void:
	var tree_item: TreeItem = _cue_items.left(p_cue)
	tree_item.set_text(Columns.NAME, p_name)


## Called when a cue's fade time is changed
func _on_cue_fade_time_changed(p_fade_time: float, p_cue: Cue) -> void:
	var tree_item: TreeItem = _cue_items.left(p_cue)
	tree_item.set_text(Columns.FADE_TIME, str(p_fade_time))


## Called when a cue's wait time is changed
func _on_cue_wait_time_changed(p_wait_time: float, p_cue: Cue) -> void:
	var tree_item: TreeItem = _cue_items.left(p_cue)
	tree_item.set_text(Columns.WAIT_TIME, str(p_wait_time))


## Called when a cue's triggermode is changed
func _on_cue_trigger_mode_changed(p_trigger_mode: Cue.TriggerMode, p_cue: Cue) -> void:
	var tree_item: TreeItem = _cue_items.left(p_cue)
	tree_item.set_text(Columns.TRIGGER_MODE, Cue.TriggerMode.keys()[p_trigger_mode].capitalize())


## Called when items are erased or added to the cue
func _update_cue_fixture_count(p_items: Array, p_cue: Cue) -> void:
	var tree_item: TreeItem = _cue_items.left(p_cue)
	tree_item.set_text(Columns.FIXTURES, str(len(p_cue.get_fixtures())))


## Resets everything
func _reset() -> void:
	_remove_cues(_cue_items.get_left())
	_tree.clear()
	_tree.set_columns(len(Columns))
	_root = _tree.create_item()
	
	for column: int in Columns.values():
		_tree.set_column_title(column, _column_config[column][0])
		_tree.set_column_expand(column, _column_config[column][1])
		_tree.set_column_custom_minimum_width(column, _column_config[column][2])
	
	_clear_selection()


## Called for all tree item selection
func _set_item_selection(item: TreeItem, column: int, selected: bool) -> void:
	var cue: Cue = _cue_items.right(item)
	
	if selected:
		var columns: Array = _selected_cues.get_or_add(cue, [])
		if column not in columns:
			columns.append(column)
		
		_selected_cue = cue
	
	else:
		var columns: Array = _selected_cues.get(cue, [])
		
		if column in columns:
			columns.erase(column)
		
		if not columns:
			if cue == _selected_cue:
				_selected_cue = null
			
			_selected_cues.erase(cue)
	
	_go_button.set_disabled(not is_instance_valid(_selected_cue))
	_delete_button.set_disabled(not is_instance_valid(_selected_cue))


## Isolates the selection to a single column
func _isolate_selection_to_column(p_column: int) -> void:
	var current: TreeItem = _tree.get_selected()
	
	for cue: Cue in _selected_cues.duplicate(true):
		for column: int in _selected_cues[cue]:
			if column != p_column:
				var tree_item: TreeItem = _cue_items.left(cue)
				
				tree_item.deselect(column)
	
	current.select(p_column)


## Called when nothing is selected in the tree
func _clear_selection() -> void:
	_tree.deselect_all()
	_selected_cues.clear()
	_selected_columns.clear()
	_selected_cue = null
	
	_go_button.set_disabled(true)
	_delete_button.set_disabled(true)


## Called when an item is edited in the tree
func _on_tree_item_edited() -> void:
	var column: int = _tree.get_edited_column()
	var value: String = _tree.get_edited().get_text(column)
	
	match column:
		Columns.IDX:
			for cue: Cue in _selected_cues:
				_cue_list.set_cue_position(cue, int(value))
		
		Columns.QID:
			for cue: Cue in _selected_cues:
				cue.set_qid(value)
		
		Columns.NAME:
			for cue: Cue in _selected_cues:
				cue.set_name(value)
		
		Columns.FADE_TIME:
			for cue: Cue in _selected_cues:
				cue.set_fade_time(float(value))
		
		Columns.WAIT_TIME:
			for cue: Cue in _selected_cues:
				cue.set_pre_wait(float(value))


## Called when a column title is clicked
func _on_tree_column_title_clicked(column: int, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT and _cue_list:
		if not Input.is_key_pressed(KEY_SHIFT):
			_clear_selection()
		
		for cue: Cue in _cue_list.get_cues():
			var tree_item: TreeItem = _cue_items.left(cue)
			tree_item.select(column)
			_set_item_selection(tree_item, column, true)


## GUI input on tree
func _on_tree_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_pending_drag = true
				_drag_start_point = _tree.get_local_mouse_position()
				
				_select_box.size = Vector2.ZERO
				_select_box.position = _drag_start_point
			
			else:
				if _is_dragging:
					get_viewport().set_input_as_handled()
				
				_is_dragging = false
				_pending_drag = false
				_select_box.hide()
			
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and _selected_cues:
			get_viewport().set_input_as_handled()
			_isolate_selection_to_column(_tree.get_selected_column())
			
			match _tree.get_selected_column():
				Columns.TRIGGER_MODE:
					_cue_trigger_option.set_position(get_global_mouse_position())
					_cue_trigger_option.popup()
				
				Columns.FIXTURES:
					pass
				
				_:
					_tree.edit_selected(true)
	
	if event is InputEventMouseMotion:
		if _pending_drag and event.position.distance_to(_drag_start_point) >= _drag_deadzone:
			_is_dragging = true
			_pending_drag = false
		
		if _is_dragging or _select_box.visible:
			get_viewport().set_input_as_handled()
			_select_box.show()
			_handle_drag_selection(event)


## Called during drag selection
func _handle_drag_selection(event: InputEventMouseMotion) -> void:
	var start_point: Vector2 = _drag_start_point
	var end_point: Vector2 = event.position
	
	_select_box.position = Vector2(
		min(start_point.x, end_point.x),
		min(start_point.y, end_point.y)
	)
	
	_select_box.size = Vector2(
		abs(end_point.x - start_point.x),
		abs(end_point.y - start_point.y)
	)
	
	var from_column: int = _tree.get_column_at_position(start_point)
	var from_item: TreeItem = _tree.get_item_at_position(start_point)
	var to_column: int = _tree.get_column_at_position(end_point)
	var to_item: TreeItem = _tree.get_item_at_position(end_point)
	
	if not from_item or not to_item:
		return
	
	var from_index: int = from_item.get_index()
	var to_index: int = to_item.get_index()
	var items_to_select: Array[TreeItem]
	
	var index_range: Array = range(to_index, from_index + 1) if from_index > to_index else range(from_index, to_index + 1)
	var column_range: Array = range(to_column, from_column + 1) if from_column > to_column else range(from_column, to_column + 1)
	
	if not Input.is_key_label_pressed(KEY_CTRL):
		_clear_selection()
	
	for index: int in index_range:
		var item: TreeItem = _root.get_child(index)
		
		for column: int in column_range:
			item.select(column)
			_set_item_selection(item, column, true)
	
	to_item.select(to_column)


## Called when a TriggerMode option is selected
func _on_cue_trigger_mode_option_index_pressed(index: int) -> void:
	for cue: Cue in _selected_cues:
		cue.set_trigger_mode(index - 1)


## Called when the Previous button is pressed
func _on_previous_pressed() -> void:
	_cue_list.go_previous()


## Called when the Go button is pressed
func _on_go_pressed() -> void:
	_cue_list.seek_to(_selected_cue)


## Called when the Next button is pressed
func _on_next_pressed() -> void:
	_cue_list.go_next()


## Called when the PlayPause button is pressed
func _on_play_pause_pressed() -> void:
	_cue_list.pause() if _cue_list.get_transport_state() else _cue_list.play()


## Called when the Stop button is pressed
func _on_stop_pressed() -> void:
	_cue_list.off()


## Called when the DeleteCue button is pressed
func _on_delete_cue_pressed() -> void:
	Interface.confirm_and_delete_components(_selected_cues.keys())


## Saves this into a dict
func _save() -> Dictionary:
	if _cue_list: 
		return { "uuid": _cue_list.uuid }
	else: 
		return {}


## Loads this from a dict
func _load(saved_data: Dictionary) -> void:
	if saved_data.get("uuid") is String:
		_object_picker_button.look_for(saved_data.uuid)

# Copyright (c) 2025 Liam Sherwin. All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.0 or later.
# See the LICENSE file for details.

class_name TaggedLineEdit extends LineEdit
## TaggedLineEdit for adding tags to line edits


## Called when a tag is added
signal tag_added(p_id)

## Called when a tag is removed
signal tag_removed(p_id)


## Gap in px between tags
@export var tag_gap: int = 2


@export_group("Nodes")

## The container used to contain all tags
var _tag_container: Control

## RefMap for int: PanelContainer
var _tags: RefMap = RefMap.new()

## The StyleBox for this LineEdit
var _style_box: StyleBox


## Ready
func _ready() -> void:
	_style_box = get_theme_stylebox("normal").duplicate()
	add_theme_stylebox_override("normal", _style_box)
	
	var margin_container: MarginContainer = MarginContainer.new()
	_tag_container = HBoxContainer.new()
	
	margin_container.add_theme_constant_override("margin_left", 5)
	margin_container.add_theme_constant_override("margin_top", 5)
	margin_container.add_theme_constant_override("margin_right", 5)
	margin_container.add_theme_constant_override("margin_bottom", 5)
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	margin_container.add_child(_tag_container)
	add_child(margin_container)
	
	if not gui_input.is_connected(_on_gui_input):
		gui_input.connect(_on_gui_input)


## Creates and adds a new tag
func create_tag(p_text: String, p_color: Color = Color.WHITE) -> int:
	var id: int = 0
	
	while id in _tags.get_left():
		id += 1
	
	var container: PanelContainer = PanelContainer.new()
	var label: Label = Label.new()
	
	container.add_theme_stylebox_override("panel", ThemeManager.StyleBoxes.ResolveBoxStyle)
	container.self_modulate = p_color
	
	label.set_text(p_text)
	container.add_child(label)
	
	(func ():
		_style_box.content_margin_left += container.get_minimum_size().x + tag_gap
	).call_deferred()
	
	_tags.map(id, container)
	_tag_container.add_child(container)
	
	tag_added.emit(id)
	return id


## Removes a tag by id
func remove_tag(p_id: int) -> bool:
	if not _tags.has_left(p_id):
		return false
	
	_remove_tag(p_id)
	
	tag_removed.emit(p_id)
	return true


## Internal: Removes a tag by id
func _remove_tag(p_id: int) -> bool:
	var container: PanelContainer = _tags.left(p_id)
	_style_box.content_margin_left -= container.get_minimum_size().x + tag_gap
	
	_tag_container.remove_child(container)
	container.queue_free()
	
	_tags.erase_left(p_id)
	return true


## Clears all tags
func clear_tags() -> void:
	for id: int in _tags.get_left():
		_remove_tag(id)


## Called for each GUI input
func _on_gui_input(p_event: InputEvent) -> void:
	if p_event is InputEventKey and p_event.is_pressed() and p_event.keycode == KEY_BACKSPACE and _tags.get_left() and caret_column == 0 :
		remove_tag(_tags.right(_tag_container.get_child(_tag_container.get_child_count() - 1)))

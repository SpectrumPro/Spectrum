# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name ListItem extends PanelContainer
## GUI component for a item in an ItemListView


## Emmited when this control is clicked on
signal select_requested(from: Control) 

## Emitted when this ListItem is double clicked
signal double_clicked()


## If this item is selected
var selected: bool = false : set = set_selected

## If this item is highlighted
var highlighted: bool = false : set = set_highlighted


## If this item is selected
var selected_color: Color = Color.WHITE

## If this item is highlighted
var highlighted_color: Color = Color.DIM_GRAY

## The color of this item
var color: Color = Color.WHITE : set = set_color


func _init() -> void:
	add_theme_stylebox_override("panel", get_theme_stylebox("panel").duplicate())


func _ready() -> void:
	$Container/IDEdit.get_line_edit().flat = true
	$Container/IDEdit.get_line_edit().add_theme_constant_override("minimum_character_width", 2)
	$Container/IDEdit.get_line_edit().add_theme_color_override("font_color", Color.hex(0x8d8d8dff))
	$Container/IDEdit.get_line_edit().add_theme_font_size_override("font_size", 13)


## Sets the nme of this item
func set_item_name(name):
	$Container/Name.text = name
	$Container/NameEdit.text = name


## Sets the color on the left hand side of this item
func set_color(p_color):
	color = p_color
	get_theme_stylebox("panel").border_color = color


## Sets whether this item should be highlighted, adds a gray border if so
func set_highlighted(is_highlighted):
	highlighted = is_highlighted
	_update_border_state()


## Sets whether this item should be selected, adds a white border if so
func set_selected(is_selected):
	selected = is_selected
	_update_border_state()


## Updates the size and color of the border
func _update_border_state() -> void:
	var new_color: Color = color
	if selected:
		new_color = selected_color
	elif highlighted:
		new_color = highlighted_color
	
	get_theme_stylebox("panel").border_color = new_color
	
	get_theme_stylebox("panel").border_width_left = 5
	
	var border_size: int = 5 if highlighted or selected else 0
	get_theme_stylebox("panel").border_width_bottom = border_size
	get_theme_stylebox("panel").border_width_top = border_size
	get_theme_stylebox("panel").border_width_right = border_size


## Adds a chip to this item, allowing to editing properties on objects 
func add_chip(object: Object, property: String, set_method: Callable, changed_signal: Signal = Signal()) -> Node:
	var panel = PanelContainer.new()
	var hbox = HBoxContainer.new()
	var input = null
	var node_signal = null
	
	match typeof(object.get(property)):
		TYPE_INT:
			input = SpinBox.new()
			input.max_value = INF
			input.value = object.get(property)
			node_signal = input.value_changed
			if not changed_signal.is_null(): changed_signal.connect(input.set_value_no_signal)
		
		TYPE_FLOAT:
			input = SpinBox.new()
			input.step = 0.1
			input.max_value = INF
			input.value = object.get(property)
			node_signal = input.value_changed
			if not changed_signal.is_null(): changed_signal.connect(input.set_value_no_signal)
			
		
		TYPE_STRING:
			input = LineEdit.new()
			input.text = object.get(property)
			node_signal = input.text_submitted
			if not changed_signal.is_null(): changed_signal.connect(input.text)
			
		
		_:
			return
	node_signal.connect(func (value: Variant):
			set_method.call(value)
	)
	
	var label: Label = Label.new()
	label.text = property.capitalize()
	label.add_theme_font_size_override("font_size", 15)
	
	hbox.add_child(label)
	hbox.add_child(input)
	
	panel.add_child(hbox)
	
	$Container/Chips.add_child(panel)
	
	return input


## Add a custem node to the chips panel
func add_chip_node(node: Control) -> void:
	node.visible = true
	$Container/Chips.add_child(node)


## Sets the method that should be called when the name LineEdit is changed in this item
func set_name_method(method: Callable) -> void:
	$Container/Name.visible = false
	$Container/NameEdit.visible = true
	
	$Container/NameEdit.text_submitted.connect(method)


## Sets the signal that should be listend to to update the name of this item
func set_name_changed_signal(p_signal: Signal) -> void:
	p_signal.connect(func (new_name: String): 
		$Container/NameEdit.text = new_name
		$Container/Name.text = new_name
	)


func set_id_tag(tag: String) -> void:
	$Container/IDTag.text = tag
	$Container/IDEdit.value = float(tag)
	$Container/IDTag.visible = tag != ""


## Sets the method that should be called when the name LineEdit is changed in this item
func set_id_method(method: Callable) -> void:
	$Container/IDTag.visible = false
	$Container/IDEdit.visible = true
	
	$Container/IDEdit.value_changed.connect(method)


## Sets the signal that should be listend to to update the name of this item
func set_id_changed_signal(p_signal: Signal) -> void:
	p_signal.connect(func (new_name): 
		$Container/IDEdit.value = float(new_name)
		$Container/IDTag.text = new_name
	)


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT:
			select_requested.emit(self)
			
			if event.double_click:
				double_clicked.emit()

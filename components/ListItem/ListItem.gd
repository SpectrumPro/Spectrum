# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

class_name ListItem extends PanelContainer
## GUI component for a item in an ItemListView


## Emmited when this control is clicked on
signal select_requested(from: Control) 


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


func _init():
	self.add_theme_stylebox_override("panel", self.get_theme_stylebox("panel").duplicate())


## Sets the nme of this item
func set_item_name(name):
	$Container/Name.text = name
	$Container/NameEdit.text = name


## Sets the color on the left hand side of this item
func set_color(color):
	self.get_theme_stylebox("panel").border_color = color



## Sets whether this item should be highlighted, adds a gray border if so
func set_highlighted(is_highlighted):
	highlighted = is_highlighted
	_update_border_state()


## Sets whether this item should be selected, adds a white border if so
func set_selected(is_selected):
	selected = is_selected
	_update_border_state()


func _update_border_state() -> void:
	
	var new_color: Color = selected_color if selected else (highlighted_color if highlighted else color)
	
	set_color(new_color)
	
	if highlighted or selected:
		self.get_theme_stylebox("panel").border_width_bottom = 5
		self.get_theme_stylebox("panel").border_width_top = 5
		self.get_theme_stylebox("panel").border_width_left = 5
		self.get_theme_stylebox("panel").border_width_right = 5
	else:
		self.get_theme_stylebox("panel").border_width_bottom = 0
		self.get_theme_stylebox("panel").border_width_top = 0
		self.get_theme_stylebox("panel").border_width_left = 5
		self.get_theme_stylebox("panel").border_width_right = 0


## Adds a chip to this item, allowing to editing properties on objects 
func add_chip(object: Object, property: String, set_method: Callable) -> void:
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
		
		TYPE_FLOAT:
			input = SpinBox.new()
			input.step = 0.1
			input.max_value = INF
			input.value = object.get(property)
			node_signal = input.value_changed
		
		TYPE_STRING:
			input = LineEdit.new()
			input.text = object.get(property)
			node_signal = input.text_submitted
		
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
	$Container/IdTag.text = tag
	$Container/IdTag.visible = tag != ""


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT:  # Check if the mouse button is released
			select_requested.emit(self)


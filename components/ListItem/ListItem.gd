# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## GUI component for a item in an ItemListView


## Emmited when this control is clicked on
signal select_requested(from: Control) 


func _init():
	self.add_theme_stylebox_override("panel", self.get_theme_stylebox("panel").duplicate())


## Sets the nme of this item
func set_item_name(name):
	$Container/Name.text = name
	$Container/NameEdit.text = name


## Sets the color on the left hand side of this item
func set_color(color):
	self.get_theme_stylebox("panel").border_color = color



## Sets whether this item should be highlighted, adds a white border if so
func set_highlighted(highlighted):
	if highlighted:
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
			input.fla
			input.value = object.get(property)
			node_signal = input.value_changed
		
		TYPE_FLOAT:
			input = SpinBox.new()
			input.step = 0.1
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


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT:  # Check if the mouse button is released
			select_requested.emit(self)


extends PanelContainer

var control_node

func _init():
	self.add_theme_stylebox_override("panel", self.get_theme_stylebox("panel").duplicate())

func set_item_name(name):
	$Container/Name.text = name

func set_color(color):
	self.get_theme_stylebox("panel").border_color = color

func set_highlighted(highlighted):
	if highlighted:
		print("setting highligted")
		self.get_theme_stylebox("panel").border_width_bottom = 5
		self.get_theme_stylebox("panel").border_width_top = 5
		self.get_theme_stylebox("panel").border_width_left = 5
		self.get_theme_stylebox("panel").border_width_right = 5
	else:
		self.get_theme_stylebox("panel").border_width_bottom = 0
		self.get_theme_stylebox("panel").border_width_top = 0
		self.get_theme_stylebox("panel").border_width_left = 5
		self.get_theme_stylebox("panel").border_width_right = 0

func dissable_buttons(dissable):
	$Container/Delete.disabled = dissable
	$Container/Edit.disabled = dissable

func _on_delete_pressed():
	if control_node.has_method("delete_request"):
		control_node.delete_request(self)

func _on_edit_pressed():
	if control_node.has_method("edit_request"):
		control_node.edit_request(self)

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT:  # Check if the mouse button is released
			if control_node.has_method("on_selected"):
				control_node.on_selected(self)


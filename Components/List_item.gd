extends PanelContainer

var control_node

func set_function_name(name):
	$Container/Name.text = name

func set_color(color):
	self.get_theme_stylebox("panel").border_color = color

func dissable_buttons(dissable):
	$Container/Delete.disabled = dissable
	$Container/Edit.disabled = dissable

func _on_delete_pressed():
	control_node.delete_request(self)

func _on_edit_pressed():
	control_node.edit_request(self)

extends PanelContainer

func set_function_name(name):
	$Container/Name.text = name

func dissable_buttons(dissable):
	$Container/Delete.disabled = dissable
	$Container/Edit.disabled = dissable

func _on_delete_pressed():
	Globals.nodes.functions.delete_request(self)

func _on_edit_pressed():
	Globals.nodes.functions.edit_request(self)

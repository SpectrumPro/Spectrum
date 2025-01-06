# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name DialogBoxContainer extends Control
## Container for Dialog boxes


## The container to store all the dialog boxes
@export var _container: VBoxContainer = null


## Removes all dialog boxes
func clear() -> void:
	for dialog: DialogBox in _container.get_children():
		_container.remove_child(dialog)
		dialog.queue_free()


## Adds and returns a default confirmation dialog
func add_confirmation_dialog(title: String) -> ConfirmationBox:
	return _add_confirmation_box(title, ConfirmationBox.DisplayMode.Default)


## Adds and returns a default confirmation dialog
func add_info_dialog(title: String) -> ConfirmationBox:
	return _add_confirmation_box(title, ConfirmationBox.DisplayMode.Info)


## Adds and returns a new delete confirmation box
func add_delete_confirmation(title: String = "") -> ConfirmationBox:
	return _add_confirmation_box(title, ConfirmationBox.DisplayMode.Delete)


## Adds a confirmation box
func _add_confirmation_box(title: String, mode: ConfirmationBox.DisplayMode) -> ConfirmationBox:
	var new_confirmation_box: ConfirmationBox = Interface.components.ConfirmationBox.instantiate()
	
	new_confirmation_box.set_mode(mode)
	if title:
		new_confirmation_box.set_title(title)
	
	return _add_dialog(new_confirmation_box)


## Adds a name dialog box
func add_name_dialog_box(title: String = "", default_text: String = "") -> NameDialogBox:
	var new_name_dialog: NameDialogBox =  Interface.components.NameDialogBox.instantiate()
	
	if title:
		new_name_dialog.set_title(title)
	new_name_dialog.set_text(default_text)
	
	return _add_dialog(new_name_dialog)


## Adds the dialog box node to the container
func _add_dialog(dialog: DialogBox) -> DialogBox:
	_container.add_child(dialog)
	show()
	move_to_front()
	
	var remove_method: Callable = func (arg=null):
		_container.remove_child(dialog)
		dialog.queue_free()
		
		if not _container.get_children():
			hide()
	
	dialog.confirmed.connect(remove_method)
	dialog.rejected.connect(remove_method)
	
	return dialog

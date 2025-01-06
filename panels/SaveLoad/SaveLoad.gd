# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name UISaveFiles extends UIPanel
## Ui panel for saving, loading, and merging files


## The item list used to display files
@export var _tree: Tree = null

## The Loading label
@export var _loading_label: Label = null

## File action buttons
@export var _file_action_buttons: Array[Button]

## Current file name label
@export var _current_file_name: LineEdit


## All the currtent listed files
var _listed_files: Array[String]

## The columns displayed
var _columns: Array[String] = ["name", "modified", "size", "version"]

## The index of _columns to sort by
var _sort_mode: int = 0

## Sort orientation, true = top down, false = bottom up
var _sort_orientation: bool = true

## All the current displayed files
var _files: Array[Dictionary]


func _ready() -> void:
	Client.connected_to_server.connect(_reload_saves)
	Core.file_name_changed.connect(_set_file_name)
	
	_reload_saves()
	_set_file_name(Core.get_file_name())
	
	_tree.set_column_title(0, "Name")
	for i in range(1, 4):
		_tree.set_column_title(i, _columns[i].capitalize())
		_tree.set_column_expand(i, false)
		_tree.set_column_custom_minimum_width(i, 100)


## Reloads the list of save files from the server
func _reload_saves() -> Promise:
	_tree.clear()
	_loading_label.show()
	_dissable_action_buttons(true)
	
	return Core.get_all_saves_from_library().then(func (files: Array):
		_loading_label.hide()
		_files = _validate_files(files)
		_update_list(_sort_files(_files))
	)


## Sets the file name
func _set_file_name(file_name: String) -> void:
	_current_file_name.text = file_name


## Sorts the files
func _validate_files(files: Array) -> Array[Dictionary]:
	var validated_files: Array[Dictionary]
	
	for file: Variant in files:
		if file is Dictionary:
			validated_files.append({
				"name": str(file.get("name", "")),
				"modifed": str(Time.get_date_string_from_unix_time(int(file.get("modified", 0)))),
				"size": String.humanize_size(int(file.get("size", 0))),
				"version": str(file.get("version", "unknown"))
			})
	
	return validated_files


## Sorts all the files 
func _sort_files(files: Array[Dictionary], sort_mode: int = _sort_mode) -> Array[Dictionary]:
	var sorted_files: Array[Dictionary] = files.duplicate()
	
	sorted_files.sort_custom(func (a, b):
		var a_item = str(a.values()[sort_mode])
		var b_item = str(b.values()[sort_mode])
		return a_item.naturalnocasecmp_to(b_item) < 0 if _sort_orientation else b_item.naturalnocasecmp_to(a_item) < 0
	)
	
	return sorted_files


## Updates the list of files from an array
func _update_list(files: Array[Dictionary]) -> void:
	_tree.clear()
	_listed_files.clear()
	
	var root: TreeItem = _tree.create_item()
	var internal_branch: TreeItem = _tree.create_item(root)
	
	internal_branch.set_text(0, "Internal Storage")
	internal_branch.set_selectable(0, false)
	
	for file: Dictionary in files:
		var file_item: TreeItem = _tree.create_item(internal_branch)
		file_item.set_text(0, file.name)
		file_item.set_text(1, file.modifed)
		file_item.set_text(2, file.size)
		file_item.set_text(3, file.version)
		_listed_files.append(file.name)


## Changes the dissabled state on the file action buttons
func _dissable_action_buttons(state: bool) -> void:
	for button: Button in _file_action_buttons:
		button.disabled = state


## Called when a column item is clicked
func _on_tree_column_title_clicked(column: int, mouse_button_index: int) -> void:
	if _sort_mode == column:
		_sort_orientation = not _sort_orientation
	else:
		_sort_mode = column
		
	_update_list(_sort_files(_files))


## Called when the user clicks the blank space below the tree
func _on_tree_nothing_selected() -> void: 
	_dissable_action_buttons(true)
	_tree.deselect_all()


## Called when the open button is pressed
func _on_open_pressed() -> void:
	var selected: TreeItem = _tree.get_selected()
	if selected:
		var file_name: String = selected.get_text(0)
		
		Interface.show_confirmation_dialog("Warning: Opening a show will erace all current components!").confirmed.connect(func ():
			if _files[selected.get_index() - 1].version != str(Details.schema_version):
				Interface.show_confirmation_dialog("Warning: This file was made in an older version of the engine. Opening it may cause errors!").confirmed.connect(func ():
					Core.reset_and_load(file_name)
				)
			else:
				Core.reset_and_load(file_name)
		)


## Saves the main ui layout
func _on_save_ui_pressed() -> void: Interface.save_to_file()

## Called when the save button is pressed
func _on_save_pressed() -> void: Core.save()


## Called when the new button is clicked
func _on_new_pressed() -> void:
	Interface.show_confirmation_dialog("Warning: Creating a show will erace all current components!").confirmed.connect(func ():
		Core.reset()
	)


## Called when the save as button is pressed
func _on_save_as_pressed() -> void:
	Interface.show_name_dialog("Save As: ", Core.get_file_name()).confirmed.connect(func (file_name: String):
		if file_name in _listed_files:
			Interface.show_confirmation_dialog("A file with the same name already exists. Would you like to override it?").confirmed.connect(func ():
				Core.save(file_name)
			)
		else:
			Core.save(file_name).then(_reload_saves)
	)


## Called when the rename button is pressed
func _on_rename_pressed() -> void:
	var selected: TreeItem = _tree.get_selected()
	
	if selected:
		var orignal_file: String = selected.get_text(0)
		Interface.show_name_dialog("New Name: ", orignal_file).confirmed.connect(func (new_name: String):
			if new_name in _listed_files:
				Interface.show_info_dialog("A file with the same name already exists.")
			else:
				Core.rename_file(orignal_file, new_name).then(_reload_saves)
		)


## Called when the delete button is pressed
func _on_delete_pressed() -> void:
	var selected: TreeItem = _tree.get_selected()
	
	if selected:
		var orignal_file: String = selected.get_text(0)
		Interface.show_delete_confirmation("Confirm deletion of: " + orignal_file + "? This can not be undone").confirmed.connect(func ():
				Core.delete_file(orignal_file).then(_reload_saves)
		)

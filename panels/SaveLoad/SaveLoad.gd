# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends PanelContainer
## Ui panel for saving, loading, and merging files

var _current_file: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if MainSocketClient.last_state == WebSocketPeer.STATE_OPEN:
		_load_from_server()
	else:
		MainSocketClient.connected_to_server.connect(func ():
			_load_from_server()
		, CONNECT_ONE_SHOT)


func refresh() -> void:
	if MainSocketClient.last_state == WebSocketPeer.STATE_OPEN:
		$VBoxContainer/ItemListView.remove_all()
		
		_load_from_server()


func _load_from_server() -> void:
	Client.send({
		"for": "engine",
		"call": "get_all_shows_from_library",
		"args": []
	}, func(shows: Array):
		$VBoxContainer/ItemListView.add_items(shows)
	)


func _on_item_list_view_selection_changed(items: Array) -> void:
	_current_file = items[0]
	$VBoxContainer/ItemListView.set_selected(items)


func _on_open_pressed() -> void:
	if _current_file:
		Client.send({
			"for": "engine",
			"call": "reset",
			"args": []
		}, func():
			Client.send({
				"for": "engine",
				"call": "load_from_file",
				"args": [_current_file]
			})
			pass
		)


func _on_save_pressed() -> void:
	var file_name: String = $VBoxContainer/HBoxContainer/PanelContainer2/HBoxContainer/FileName.text
	
	if file_name:
		Client.send({
			"for": "engine",
			"call": "save",
			"args": [file_name]
		}, func ():
			refresh()
		)
	
	Interface.save_to_file()


func _on_import_pressed() -> void:
	$ImportLocalFileDialog.show()


func _on_import_local_file_dialog_file_selected(path: String) -> void:
	var saved_file = FileAccess.open(path, FileAccess.READ)

	if not saved_file:
		print("Unable to open file: \"", path, "\", ",  error_string(FileAccess.get_open_error()))
		return
	
	var serialized_data: Dictionary = JSON.parse_string(saved_file.get_as_text())
	print(serialized_data)
	
	Client.send({
		"for": "engine",
		"call": "load",
		"args": [serialized_data]
	}, func ():
		
		Client.send({
			"for": "engine",
			"call": "save",
			"args": [$ImportLocalFileDialog.current_file]
			}, func ():
				refresh()
		)
	)

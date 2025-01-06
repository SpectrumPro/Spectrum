# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Controller, licensed under the GPL v3.

class_name CustomTabContainer extends Control
## Custem tab bar container, contains all the tabs


## The tab bar to control this tab container
@export var _tab_bar: TabBar = null


## The last opened tab
var _last_tab: Control = null


func _ready() -> void:
	_tab_bar.tab_changed.connect(change_tab)


## Add a tab
func add_tab(text: String, control: Control) -> int:
	control.hide()
	
	add_child(control, true)
	_tab_bar.add_tab(text)
	
	return control.get_index()


## Change the current tab
func change_tab(idx: int) -> void:
	var children: Array = get_children()
	
	if idx in range(len(children)):
		if _last_tab:
			_last_tab.hide()
		
		_tab_bar.current_tab = idx
		children[idx].show()
		_last_tab = children[idx]


## Remove a tab
func remove_tab(idx: int) -> void:
	var children: Array[Node] = get_children()
	
	if idx in range(len(children)):
		if _last_tab == children[idx]:
			_last_tab = null
		
		_tab_bar.remove_tab(idx)
		children[idx].queue_free()
		remove_child(children[idx])
		
		change_tab(_tab_bar.current_tab)


## Gets the title of a tab
func get_tab_title(idx: int) -> String:
	return _tab_bar.get_tab_title(idx)


## Sets the title of a tab
func set_tab_title(idx: int, title: String) -> void:
	_tab_bar.set_tab_title(idx, title)


## Returns the current tab id
func get_current_tab() -> int:
	return _tab_bar.current_tab

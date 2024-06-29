# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## Custem tab bar container, contains all the tabs


## The last opened tab
var _last_tab: Control = null


func change_tab(idx: int) -> void:
	var children: Array = get_children()
	
	if idx in range(len(children)):
		if _last_tab:
			_last_tab.hide()
		children[idx].show()
		
		_last_tab = children[idx]


func add_tab(node: Control, switch_to: bool = true) -> void:
	node.hide()
	add_child(node, true)
	
	if switch_to:
		change_tab(len(get_children()))

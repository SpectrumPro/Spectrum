# Copyright (c) 2024 Liam Sherwin, All rights reserved.
# This file is part of the Spectrum Lighting Engine, licensed under the GPL v3.

class_name CreatFunctionComponent extends PanelContainer
## UI component to create a new function


## Emitted once an object is hidden
signal created()

## Emitted when object creation is canceled
signal canceled()

## Emitted once the new component is added to the engine
signal component_added(component: EngineComponent)


## The item list node
@onready var item_list: ItemList = $VBoxContainer/ItemList

## The description label 
@onready var description: Label = $VBoxContainer/PanelContainer2/HBoxContainer/Description


## Auto hides this node when a button is pushed
@export var auto_hide: bool = false


func _ready() -> void:
	ClassList.function_classes_updated.connect(_reload_list)


## Reloads the list of function classes
func _reload_list() -> void:
	item_list.clear()
	
	for classname: String in ClassList.get_function_classes():
		item_list.add_item(classname.capitalize(), ClassList.get_class_icon(classname))
	
	item_list.sort_items_by_text()


## Called when the create button is pussed
func _on_create_pressed() -> void:
	if item_list.get_selected_items():
		var classname: String = item_list.get_item_text(item_list.get_selected_items()[0])
		
		Core.create_component(classname, "", func(component: EngineComponent):
			component_added.emit(component)
		)
	
	created.emit()
	if auto_hide: hide()


## Called when the cancel button is pussed
func _on_cancel_pressed() -> void:
	canceled.emit()
	if auto_hide: hide()
	

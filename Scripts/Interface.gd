extends Node

@onready var _root_node : Control = get_tree().root.get_node("Main")

@onready var components := {             
	"close_button":ResourceLoader.load("res://Components/Close Button/Close_button.tscn"),
	"warning":ResourceLoader.load("res://Components/Warning/Warning.tscn"),
	"list_item":ResourceLoader.load("res://Components/List Item/List_item.tscn"),
	"accept_dialog":ResourceLoader.load("res://Components/Accept Dialog/Accept_dialog.tscn"),
	"channel_slider":ResourceLoader.load("res://Components/Channel Slider/Channel_slider.tscn"),
	"virtual_fixture":ResourceLoader.load("res://Components/Virtual Fixture/Virtual_fixture.tscn"),
	"window":ResourceLoader.load("res://Components/Window/Window.tscn"),
	"trigger_button":ResourceLoader.load("res://Components/Trigger Button/TriggerButton.tscn"),
	"file_load_menu": ResourceLoader.load("res://Components/File Load Menu/FileLoadMenu.tscn"),
	"file_save_menu": ResourceLoader.load("res://Components/File Save Menu/FileSaveMenu.tscn")
}

@onready var panels : Dictionary = {             
	"3d":ResourceLoader.load("res://Panels/3D/3d.tscn"),
	"add_fixture":ResourceLoader.load("res://Panels/Add Fixture/Add_fixture.tscn"),
	"fixtures":ResourceLoader.load("res://Panels/Fixtures/Fixtures.tscn"),
	"settings":ResourceLoader.load("res://Panels/Settings/Settings.tscn"),
	"virtual_fixtures":ResourceLoader.load("res://Panels/Virtual Fixtures/Virtual_fixtures.tscn"),
	"window_control":ResourceLoader.load("res://Panels/Window Control/Window_control.tscn"),
}

@onready var icons := {
	"menue":load("res://Assets/Icons/menu.svg"),
	"center":load("res://Assets/Icons/Center.svg")
	
}

@onready var shaders := {
	"invert":load("res://Assets/Shaders/Invert.tres"),
}


func _ready() -> void:
	OS.set_low_processor_usage_mode(true)
	
	Core.universes_removed.connect(func (universes: Array):
		Values.remove_from_selection_value("selected_universes", universes)
	)
	Core.fixtures_removed.connect(func (fixtures: Array): 
		Values.remove_from_selection_value("selected_fixtures", fixtures)
	)


func open_panel_in_window(panel_name:String) -> Variant:
	if panel_name in panels:
		var new_window_node : Window = components.window.instantiate()
		new_window_node.add_child(panels[panel_name].instantiate())
		_root_node.add_child(new_window_node)
		return new_window_node
	else: 
		return false

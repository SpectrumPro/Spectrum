# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## GUI element for managing fixtures, and fixture groups

@export var physical_fixture_list: NodePath
@export var fixture_groups_list: NodePath

var active_fixtures : Array = []
var last_selected_node: Control

func _ready() -> void:
	Globals.subscribe("reload_fixtures", self.reload_fixtures)
	Globals.subscribe("active_fixtures", self.set_active_fixtures)


func delete_request(node:Control) -> void :
	## Called when the delete button is clicked on a fixture List_Item
	
	var confirmation_dialog: AcceptDialog = Globals.components.accept_dialog.instantiate()
	confirmation_dialog.dialog_text = "Are you sure you want to delete this? This action can not be undone"
	
	confirmation_dialog.confirmed.connect((
	func(node):
		
		var fixture: Fixture = node.get_meta("fixture")
		fixture.config.universe.remove_fixture(fixture)
		
		Globals.call_subscription("reload_fixtures")
	).bind(node))
	
	add_child(confirmation_dialog)


func edit_request(node:Control) -> void:
	## WIP function to edit a fixture, change channel, type, universe, ect
	pass


func on_selected(selected_node:Control) -> void:
	## Called when the user clicks on a fixture List_Item
	
	if Input.is_key_pressed(KEY_SHIFT) and last_selected_node:
		var children: Array[Node] = self.get_node(physical_fixture_list).get_children()
		var pos_1: int = children.find(last_selected_node)
		var pos_2: int = children.find(selected_node)
		
		if pos_1 > pos_2:
			var x = pos_1
			pos_1 = pos_2
			pos_2 = x
		
		var fixtures_to_select: Array = []
		
		for i in range(pos_1, pos_2+1):
			fixtures_to_select.append(children[i].get_meta("fixture"))
		
		Globals.set_value("active_fixtures", fixtures_to_select)
		
	else:
		last_selected_node = selected_node
		Globals.set_value("active_fixtures", [selected_node.get_meta("fixture")])


func reload_fixtures() -> void:
	for node in get_node(physical_fixture_list).get_children():
		node.get_parent().remove_child(node)
		node.queue_free()
	
	for universe in Globals.universes.values():
		for fixture in universe.get_fixtures().values():
			var node_to_add : Control = Globals.components.list_item.instantiate()
			node_to_add.control_node = self
			node_to_add.set_item_name(fixture.meta.fixture_name + " | " + universe.get_universe_name() + " CH: " + str(fixture.channel) + "-" + str(fixture.channel+fixture.length-1))
			node_to_add.name = fixture.uuid
			node_to_add.set_meta("fixture", fixture)
			get_node(physical_fixture_list).add_child(node_to_add)
			
	set_active_fixtures(active_fixtures)


func set_active_fixtures(fixtures:Array) -> void:
	for fixture in get_node(physical_fixture_list).get_children():
		fixture.set_highlighted(false)
	active_fixtures = fixtures
	
	for fixture: Fixture in active_fixtures:
		get_node(physical_fixture_list).get_node(fixture.uuid).set_highlighted(true)
	pass


func _on_new_physical_fixture_pressed() -> void:
	Globals.open_panel_in_window("add_fixture")


func _on_new_fixture_group_pressed() -> void:
	pass


func _on_select_all_pressed() -> void:
	
	var fixtures_to_select: Array = []
	
	for list_item: Control in get_node(physical_fixture_list).get_children():
		fixtures_to_select.append(list_item.get_meta("fixture"))
	
	Globals.set_value("active_fixtures", fixtures_to_select)


func _on_select_none_pressed() -> void:
	Globals.set_value("active_fixtures", [])

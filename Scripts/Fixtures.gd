extends Control

var active_fixtures = []

func _ready():
	Globals.subscribe("edit_mode", self.on_edit_mode_changed)
	Globals.subscribe("reload_fixtures", self.reload_fixtures)
	Globals.subscribe("active_fixtures", self.set_active_fixtures)

func delete_request(node):
	var fixture_info = node.get_meta("fixture_info")
	fixture_info.universe.remove_fixture(fixture_info.channel)

func edit_request(node):
	print(node.get_meta("fixture_info"))

func on_selected(node):
	Globals.set_value("active_fixtures", [node.get_meta("fixture")])

func on_edit_mode_changed(edit_mode):

	for function_item in Globals.nodes.physical_fixture_list.get_children():
		function_item.dissable_buttons(not edit_mode)
		
	for function_item in Globals.nodes.fixture_groups_list.get_children():
		function_item.dissable_buttons(not edit_mode)

func reload_fixtures():
	print("reloading")
	for node in Globals.nodes.physical_fixture_list.get_children():
		node.queue_free()
	
	
	for universe in Globals.universes.values():
		print(universe.get_fixtures())
		for fixture in universe.get_fixtures().values():
			
			print(fixture)
			
			var node_to_add = Globals.components.list_item.instantiate()
			node_to_add.control_node = self
			node_to_add.set_item_name(fixture.config.fixture_name)
			node_to_add.name = fixture.config.uuid
			node_to_add.set_meta("fixture", fixture)
			Globals.nodes.physical_fixture_list.add_child(node_to_add)

func set_active_fixtures(fixtures):
	print(get_children())
	for fixture in active_fixtures:
		Globals.nodes.physical_fixture_list.get_node(fixture.config.uuid).set_highlighted(false)
	active_fixtures = fixtures
	for fixture in active_fixtures:
		Globals.nodes.physical_fixture_list.get_node(fixture.config.uuid).set_highlighted(true)

func _on_new_physical_fixture_pressed():
	Globals.nodes.add_fixture_window.show()

func _on_new_fixture_group_pressed():
	pass

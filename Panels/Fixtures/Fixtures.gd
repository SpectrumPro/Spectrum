extends Control

var active_fixtures : Array[Fixture] = []

func _ready() -> void:
	Globals.subscribe("edit_mode", self.on_edit_mode_changed)
	Globals.subscribe("reload_fixtures", self.reload_fixtures)
	Globals.subscribe("active_fixtures", self.set_active_fixtures)

func delete_request(node:Control):
	var confirmation_dialog : AcceptDialog = Globals.components.accept_dialog.instantiate()
	confirmation_dialog.dialog_text = "Are you sure you want to delete this? This action can not be undone"
	confirmation_dialog.confirmed.connect((
	func(node):
		var fixture = node.get_meta("fixture")
		fixture.config.universe.remove_fixture(fixture)
		
		Globals.call_subscription("reload_fixtures")
	).bind(node))
	add_child(confirmation_dialog)
	
func edit_request(node):
	pass

func on_selected(node:Control):
	if Input.is_key_pressed(KEY_SHIFT):
		pass
	else:
		Globals.set_value("active_fixtures", [node.get_meta("fixture")])

func on_edit_mode_changed(edit_mode):
	for function_item in Globals.nodes.physical_fixture_list.get_children():
		function_item.dissable_buttons(not edit_mode)
		
	for function_item in Globals.nodes.fixture_groups_list.get_children():
		function_item.dissable_buttons(not edit_mode)

func reload_fixtures():
	for node in Globals.nodes.physical_fixture_list.get_children():
		node.get_parent().remove_child(node)
		node.queue_free()
	
	for universe in Globals.universes.values():
		for fixture in universe.get_fixtures().values():
						
			var node_to_add = Globals.components.list_item.instantiate()
			node_to_add.control_node = self
			node_to_add.set_item_name(fixture.config.fixture_name + " | " + universe.get_universe_name() + " CH: " + str(fixture.config.channel) + "-" + str(fixture.config.channel+fixture.config.length-1))
			node_to_add.name = fixture.config.uuid
			node_to_add.set_meta("fixture", fixture)
			Globals.nodes.physical_fixture_list.add_child(node_to_add)
			
	set_active_fixtures(active_fixtures)
	
func set_active_fixtures(fixtures:Array[Fixture]):
	for fixture in Globals.nodes.physical_fixture_list.get_children():
		fixture.set_highlighted(false)
	active_fixtures = fixtures
	
	for fixture in active_fixtures:
		Globals.nodes.physical_fixture_list.get_node(fixture.config.uuid).set_highlighted(true)

func _on_new_physical_fixture_pressed():
	Globals.nodes.add_fixture_window.show()

func _on_new_fixture_group_pressed():
	pass

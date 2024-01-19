extends Control

func _ready():
	Globals.subscribe("edit_mode", self.on_edit_mode_changed)
	Globals.nodes.add_fixture_button.pressed.connect(self.new_physical_fixture)

func delete_request(node):
	node.queue_free()

func edit_request(node):
	print(node)

func on_edit_mode_changed(edit_mode):
	for function_item in Globals.nodes.virtual_fixture_list.get_children():
		function_item.dissable_buttons(not edit_mode)
		
	for function_item in Globals.nodes.physical_fixture_list.get_children():
		function_item.dissable_buttons(not edit_mode)
		
	for function_item in Globals.nodes.fixture_groups_list.get_children():
		function_item.dissable_buttons(not edit_mode)

func new_virtual_fixture():
	var node_to_add = Globals.components.list_item.instantiate()
	node_to_add.set_item_name("Virtual Fixture")
	node_to_add.control_node = self
	Globals.nodes.virtual_fixture_list.add_child(node_to_add)
	
func new_physical_fixture(fixture_manifest={}, options={}):
	if not fixture_manifest:
		fixture_manifest = Globals.nodes.add_fixture_menu.current_fixture
		options = Globals.nodes.add_fixture_menu.options
	print(fixture_manifest.name)
	print(options)
	
func new_fixture_groups():
	var node_to_add = Globals.components.list_item.instantiate()
	node_to_add.set_item_name("Fixture Group")
	node_to_add.control_node = self
	Globals.nodes.fixture_groups_list.add_child(node_to_add)


func _on_new_virtual_fixture_pressed():
	new_virtual_fixture()


func _on_new_physical_fixture_pressed():
	Globals.nodes.add_fixture_menu.show()

func _on_new_fixture_group_pressed():
	new_fixture_groups()

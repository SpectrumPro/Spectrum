extends GraphEdit

var old_active_fixtures = []
var locally_selected_fixtures = []
var add_button
var position_offset = Vector2(100, 100)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_button = _add_menu_hbox_button("Add Selected Fixture", self.add_fixture, "Add the selected fixtures to the view", true)
	_add_menu_hbox_button("Delete", self.request_delete, "Delete the selected virtual fixtures, this does NOT delete the underlying fixture")
	Globals.subscribe("active_fixtures", self.active_fixtures_changed)

func _add_menu_hbox_button(content, method, tooltip="", disabled=false):
	var button = Button.new()
	if content is Texture2D:
		button.icon = content
	else:
		button.text = content
	button.pressed.connect(method)
	button.tooltip_text = tooltip
	button.disabled = disabled
	self.get_menu_hbox().add_child(button)
	return button

func add_fixture():
	for fixture in Globals.get_value("active_fixtures"):
		var node_to_add = Globals.components.virtual_fixture.instantiate()
		fixture.add_virtual_fixture(node_to_add)
		node_to_add.control_node = fixture
		node_to_add.set_highlighted(true)
		node_to_add.position_offset += position_offset
		position_offset += Vector2(5, 5)
		add_child(node_to_add)


func request_delete():
	var to_remove = locally_selected_fixtures.duplicate()
	for virtual_fixture in to_remove:
		virtual_fixture.control_node.remove_virtual_fixture(virtual_fixture)
		virtual_fixture.queue_free()
		locally_selected_fixtures.erase(virtual_fixture)

func from(config, control_fixture):
	var node_to_add = Globals.components.virtual_fixture.instantiate()
	node_to_add.position_offset = Vector2(config.position_offset.x, config.position_offset.y)
	node_to_add.control_node = control_fixture
	control_fixture.add_virtual_fixture(node_to_add)
	add_child(node_to_add)
  
func active_fixtures_changed(new_active_fixtures:Array):
	
	add_button.disabled = true if new_active_fixtures == [] else false
	
	for virtual_fixture in get_children():
		virtual_fixture.set_highlighted(false)
	
	for active_fixture in new_active_fixtures:
		for virtual_fixture in active_fixture.virtual_fixtures:
			virtual_fixture.set_highlighted(true)

	old_active_fixtures = new_active_fixtures
#
func _on_virtual_fixture_selected(node):
	if node not in locally_selected_fixtures:
		locally_selected_fixtures.append(node)
	Globals.select_fixture(node.control_node)
	
func _on_virtual_fixture_deselected(node):
	locally_selected_fixtures.erase(node)
	Globals.deselect_fixture(node.control_node)

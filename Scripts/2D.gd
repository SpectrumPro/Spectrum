extends GraphEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	_add_menu_hbox_button("Add Virtual Fixture", self.add_fixture)
	_add_menu_hbox_button("Delete Virtual Fixture", self.request_delete)

func _add_menu_hbox_button(content, method):
	var button = Button.new()
	if content is Texture2D:
		button.icon = content
	else:
		button.text = content
	button.pressed.connect(method)
	self.get_menu_hbox().add_child(button)
	return button

func add_fixture():
	if Globals.get_value("active_fixtures"):
		for fixture in Globals.get_value("active_fixtures"):
			var node_to_add = Globals.components.virtual_fixture.instantiate()
			fixture.add_virtual_fixture(node_to_add)
			add_child(node_to_add)

func request_delete(node):
	print(node)

func from(config, control_fixture):
	var node_to_add = Globals.components.virtual_fixture.instantiate()
	node_to_add.position_offset = Vector2(config.position_offset.x, config.position_offset.y)
	control_fixture.add_virtual_fixture(node_to_add)
	add_child(node_to_add)

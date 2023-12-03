extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("right_click")  and get_parent().get_node("TabContainer").get_current_tab_control().name == "Console":
		self.position = get_global_mouse_position()
		self.visible = true
		
func _input(event):
	if (event is InputEventMouseButton) and event.pressed and get_parent().get_node("TabContainer").get_current_tab_control().name == "Console":
		var evLocal = make_input_local(event)
		if !Rect2(Vector2(0,0),self.size).has_point(evLocal.position):
			self.visible = false


func add_node_button_clicked():
	self.visible = true
	self.position = Vector2(220,100)

func _on_node_list_item_clicked(_index, _at_position, _mouse_button_index):
	self.visible = false

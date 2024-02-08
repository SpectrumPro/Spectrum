extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
 
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_node_editor_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and self.visible:
			var evLocal = make_input_local(event)
			if !Rect2(Vector2(0,0),self.size).has_point(evLocal.position):
				self.visible = false
				
		if event.pressed and event.button_index == 2:
			self.position = get_global_mouse_position()
			self.visible = true

func add_node_button_clicked():
	self.visible = true
	self.position = Vector2(220,100)
	self.move_to_front()

func _on_item_clicked(_index, _at_position, _mouse_button_index):
	self.visible = false

extends ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
 
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_console_editor_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and self.visible:
			var evLocal = make_input_local(event)
			if !Rect2(Vector2(0,0),self.size).has_point(evLocal.position):
				self.visible = false

func add_widget_button_clicked(position):
	self.visible = true
	self.position = position
	self.move_to_front()

func _on_item_clicked(_index, _at_position, _mouse_button_index):
	self.visible = false
	self.deselect_all()

extends Window

func _show():
	self.popup()


func _on_close_requested():
	self.visible = false

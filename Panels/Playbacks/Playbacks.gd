extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Core.scenes_added.connect(self.reload)
	Core.scenes_removed.connect(self.reload)
	Core.scene_name_changed.connect(self.reload)
	reload()

func reload(arg1=null, arg2=null) -> void:
	for old_playback: Control in $Container.get_children():
		$Container.remove_child(old_playback)
		old_playback.queue_free()
	
	for scene: Scene in Core.scenes.values():
		var new_node = Interface.components.PlaybackRow.instantiate()
		
		$Container.add_child(new_node)
		
		new_node.button1.toggle_mode = true
		new_node.button1.toggled.connect(scene.set_enabled)
		new_node.button1.set_label_text(scene.name)
		scene.percentage_step_changed.connect(new_node.button1.set_value)
		scene.state_changed.connect(new_node.button1.set_pressed_no_signal)
		
		new_node.button2.set_label_text("Enable")
		new_node.button2.pressed.connect(scene.set_enabled.bind(true))
		
		new_node.button3.set_label_text("Flash On")
		new_node.button3.button_down.connect(scene.flash_hold.bind(0))
		new_node.button3.button_up.connect(scene.flash_release.bind())
		
		new_node.button4.hide()
		
		new_node.button5.set_label_text("Disable")
		new_node.button5.pressed.connect(scene.set_enabled.bind(false))
		
		
		new_node.slider.value_changed.connect(scene.set_step_percentage)
		scene.percentage_step_changed.connect(new_node.slider.set_value_no_signal)
		

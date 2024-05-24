# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends GridContainer
## Temp ui panel for triggering scenes

func _ready() -> void:
	Core.scenes_added.connect(self._reload_buttons)
	Core.scenes_removed.connect(self._reload_buttons)
	Core.scene_name_changed.connect(self._reload_buttons)


func _reload_buttons(arg1=null, arg2=null) -> void:
	## Reloads the buttons in the ui
	
	for old_button: Button in self.get_children():
		self.remove_child(old_button)
		old_button.queue_free()
	
	for scene: Scene in Core.scenes.values():
		var button_to_add: Button = Interface.components.trigger_button.instantiate()
		
		button_to_add.set_label_text(scene.name)
		button_to_add.button_down.connect(
			func():
				scene.enabled = true
		)
		button_to_add.button_up.connect(
			func():
				scene.enabled = false
		)
		
		button_to_add.set_pressed_no_signal(scene.enabled)
		
		self.add_child(button_to_add)


func _on_resized() -> void:
	self.columns = clamp(int(self.size.x / 110), 1, INF)

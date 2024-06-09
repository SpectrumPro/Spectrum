# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends GridContainer
## Temp ui panel for triggering scenes

func _ready() -> void:
	Core.scenes_added.connect(self._reload_buttons)
	Core.scenes_removed.connect(self._reload_buttons)
	Core.scene_name_changed.connect(self._reload_buttons)
	_reload_buttons()

func _reload_buttons(arg1=null, arg2=null) -> void:
	## Reloads the buttons in the ui
	
	for old_button: Button in self.get_children():
		self.remove_child(old_button)
		old_button.queue_free()
	
	for scene: Scene in Core.scenes.values():
		var button_to_add: Button = Interface.components.TriggerButton.instantiate()
		
		button_to_add.set_label_text(scene.name)
		
		button_to_add.toggled.connect(
			func(state):
				scene.set_enabled(state)
		)
		
		scene.state_changed.connect(button_to_add.set_pressed_no_signal)
		scene.percentage_step_changed.connect(button_to_add.set_value)
		
		button_to_add.set_pressed_no_signal(scene.enabled)
		
		self.add_child(button_to_add)


func _on_resized() -> void:
	self.columns = clamp(int(self.size.x / 90), 1, INF)

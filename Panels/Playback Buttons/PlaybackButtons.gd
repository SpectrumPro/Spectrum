# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## Temp ui panel for triggering scenes

func _ready() -> void:
	Core.scenes_added.connect(self._reload_buttons)
	Core.scenes_removed.connect(self._reload_buttons)


func _reload_buttons(_scene) -> void:
	## Reloads the buttons in the ui
	
	for old_button: Button in self.get_children():
		self.remove_child(old_button)
		old_button.queue_free()
	
	for scene: Scene in Core.scenes.values():
		var button_to_add: Button = Globals.components.trigger_button.instantiate()
		
		button_to_add.set_label_text(scene.name)
		button_to_add.toggled.connect(
			func(state):
				scene.enabled = state
		)
		
		self.add_child(button_to_add)


func _on_resized() -> void:
	self.columns = int(self.size.x / 110)

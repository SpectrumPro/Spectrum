# Copyright (c) 2024 Liam Sherwin
# All rights reserved.

extends Control
## GUI element for managing functions

@export var functions_list: NodePath

func _ready() -> void:
	Core.scene_added.connect(self._reload_functions)
	Core.scene_removed.connect(self._reload_functions)


func delete_request(node:Control) -> void :
	## Called when the delete button is clicked on a function List_Item
	
	var confirmation_dialog: AcceptDialog = Globals.components.accept_dialog.instantiate()
	confirmation_dialog.dialog_text = "Are you sure you want to delete this? This action can not be undone"
	
	confirmation_dialog.confirmed.connect((
	func(node):
		
		var scene: Scene = node.get_meta("function")
		scene.engine.remove_scene(scene)
		
	).bind(node))
	
	add_child(confirmation_dialog)


func edit_request(node:Control) -> void:
	## WIP function to edit a fixture, change channel, type, universe, ect
	pass

func _reload_functions(_scene=null) -> void:
	## Reload the list of fixtures
	
	for node in get_node(functions_list).get_children():
		node.get_parent().remove_child(node)
		node.queue_free()
	
	for scene: Scene in Core.scenes.values():
		var node_to_add : Control = Globals.components.list_item.instantiate()
		node_to_add.control_node = self
		node_to_add.set_item_name(scene.name)
		node_to_add.name = scene.uuid
		node_to_add.set_meta("function", scene)
		get_node(functions_list).add_child(node_to_add)
			

extends Control

var functions = {
	"scenes":{},
	"effects":{},
	"cues":{},
}

func _ready():
	Globals.subscribe("edit_mode", self.on_edit_mode_changed)

func on_edit_mode_changed(edit_mode):
	for function_item in Globals.nodes.scenes_list.get_children():
		function_item.dissable_buttons(not edit_mode)
		
	for function_item in Globals.nodes.effects_list.get_children():
		function_item.dissable_buttons(not edit_mode)
		
	for function_item in Globals.nodes.cues_list.get_children():
		function_item.dissable_buttons(not edit_mode)

func new_scene():
	var node_to_add = Globals.components.function_list_item.instantiate()
	node_to_add.set_function_name("Scene")
	Globals.nodes.scenes_list.add_child(node_to_add)
	
func new_effect():
	var node_to_add = Globals.components.function_list_item.instantiate()
	node_to_add.set_function_name("Effect")
	Globals.nodes.effects_list.add_child(node_to_add)
	
func new_cue():
	var node_to_add = Globals.components.function_list_item.instantiate()
	node_to_add.set_function_name("Cue")
	Globals.nodes.cues_list.add_child(node_to_add)
	
func _on_new_scene_pressed():
	new_scene()

func _on_new_effect_pressed():
	new_effect()

func _on_new_cue_list_pressed():
	new_cue()

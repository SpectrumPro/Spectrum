# WIP
extends TabContainer

var last_click_time := 0
var double_click_threshold := 0.5  # Adjust this as needed

func _ready():
	#set_tab_button_icon(get_current_tab(), load("res://Assets/Icons/close.svg"))
	pass
func _on_tab_clicked(tab_index):
	#if not get_current_tab() == get_previous_tab():
		#set_tab_button_icon(get_current_tab(), load("res://Assets/Icons/close.svg"))
		#set_tab_button_icon(get_previous_tab(), Texture2D.new())
	pass
	#var current_time = Time.get_ticks_msec() / 1000.0
	#
	#if current_time - last_click_time < double_click_threshold:
		## Double click detected
		#on_double_click(tab_index)
	#else:
		## Single click, update last click time
		#last_click_time = current_time

	
func on_double_click(tab_index):

	create_new_window(tab_index)

func create_new_window(tab_index):
	# Implement the logic to pop out the tab into a new window
	# You can use scenes, instancing, or other techniques based on your project structure
	
	# Example: Duplicate the tab's content and add it to a new window
	var tab_content = get_tab_control(tab_index)
	
	# Create a new window scene and instance it
	var new_window_instance = Window.new()

	# Add the tab's content to the new window
	var duplicated_content = tab_content.duplicate()
	duplicated_content.visible = true
	duplicated_content.set_anchors_preset(15)
	
	new_window_instance.add_child(duplicated_content)
	get_tree().get_root().add_child(new_window_instance)
	# Add the new window to the scene or show it as needed
	new_window_instance.visible = true


func _on_tab_button_pressed(tab):
	if tab == get_current_tab():
		set_tab_hidden(tab, true)

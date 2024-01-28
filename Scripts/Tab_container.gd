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
	#pass
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if current_time - last_click_time < double_click_threshold:
		# Double click detected
		on_double_click(tab_index)
	else:
		# Single click, update last click time
		last_click_time = current_time

	
func on_double_click(tab_index):

	create_new_window(tab_index)

func create_new_window(tab_index):
	var node_to_replace = get_tab_control(tab_index)
	var new_window_node = Window.new()
	
	new_window_node.name = node_to_replace.name
	new_window_node.close_requested.connect(self.window_close_request.bind(str(node_to_replace.name)))
	new_window_node.set_initial_position(Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_KEYBOARD_FOCUS)
	new_window_node.size = DisplayServer.window_get_size()
	
	var bg = ColorRect.new()
	bg.color = Color.hex(0x232323ff)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.name = "_window_backdrop"
	new_window_node.add_child(bg)
	
	node_to_replace.replace_by(new_window_node)
	node_to_replace.queue_free()

func window_close_request(node_name):
	var node_to_replace = get_node(node_name)
	var new_control_node = Control.new()
	
	new_control_node.name = node_name
	
	node_to_replace.remove_child(node_to_replace.get_node("_window_backdrop"))
	node_to_replace.replace_by(new_control_node)
	node_to_replace.queue_free()

func _on_tab_button_pressed(tab):
	if tab == get_current_tab():
		set_tab_hidden(tab, true)

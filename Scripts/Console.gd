extends GraphEdit


@onready var widget_list = get_parent().get_parent().get_parent().get_node("Console List/WidgetList")                                                                             
@onready var name_input = get_parent().get_node("MarginContainer/VBoxContainer/name/LineEdit")
@onready var color_input = get_parent().get_node("MarginContainer/VBoxContainer/color/ColorPickerButton")
@onready var connection_input_button = get_parent().get_node("MarginContainer/VBoxContainer/connection/OptionButton")
@onready var side_bar = get_parent().get_node("MarginContainer")
@onready var node_editor = get_parent().get_parent().get_node("Node Editor")
@onready var external_input_button = get_parent().get_node("MarginContainer/VBoxContainer/HBoxContainer/External Input")
@onready var console_list = get_parent().get_parent().get_parent().get_node("Console List")

var built_in_widget = {
	"Slider":"Slider"
}

var widget_index = 0
var selected_widget = null
var connection_button_list = []
var connections = {}
var input_mode = "action"
var external_inputs = {}

func _ready():
#	Add build in widget to right click menue

	for node in built_in_widget:
		widget_list.add_item(node)

#	Add the "Add Widget" button to the GraphEdit's menue
	var add_node_button = Button.new()
	add_node_button.text = "Add Widget"
	add_node_button.pressed.connect(console_list.add_node_button_clicked)
	self.get_menu_hbox().add_child(add_node_button)
	
#	Init Midi inputs
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())
	
func _input(input_event):
#	Listen for midi inputs
	if input_event is InputEventMIDI:
#		If input mode == listen, program will listen for the next input event and asign that to the selected widget
		if input_mode == "listen":
			input_mode = "action"
			
			external_input_button.button_pressed = false
			external_input_button.release_focus()
			var controller_number = input_event.controller_number
			var message = input_event.message
			var pitch = input_event.pitch

			# Save the MIDI event in the dictionary, so it can be looked up later.
			external_inputs[controller_number] = external_inputs.get(controller_number, {})
			external_inputs[controller_number][message] = external_inputs[controller_number].get(message, {})
			external_inputs[controller_number][message][pitch] = selected_widget
#		If input mode == action, program will check if current input is saved in the midi dictnary
		elif input_mode == "action":
			var connected_widget = external_inputs.get(input_event.controller_number, {}).get(input_event.message, {}).get(input_event.pitch, false)
#			I may not need to check again for external inputs 2 lines below, dont have midi controller on me, so cant check currently, will fix soon
			if connected_widget:
				external_inputs[input_event.controller_number][input_event.message][input_event.pitch].external_input(input_event.controller_value)
func _process(_delta):
	pass

func set_connection_button_list(list):
#	Sets connections list when Node_system remakes it after removing or adding nodes
	connection_button_list = list
	
func remove_connection(node):
	if connections.has(node):
		connections[node].connection = false

func _on_widget_list_item_clicked(index, _at_position, _mouse_button_index):
	print("res://Widgets/" + built_in_widget[widget_list.get_item_text(index)] + ".tscn")
	var node_to_add = load("res://Widgets/" + built_in_widget[widget_list.get_item_text(index)] + ".tscn").instantiate()
	node_to_add.position_offset = (get_viewport().get_mouse_position() + self.scroll_offset) / self.zoom
#	set_editable_instance(node_to_add, true)
	node_to_add.name = node_to_add.name + str(widget_index)
	node_to_add.get_node("VBoxContainer/Label").text = "Slider " + str(widget_index)
	self.add_child(node_to_add)
	widget_index += 1

func _on_node_selected(node):
	selected_widget = node
	side_bar.visible = true
	name_input.text = node.get_node("VBoxContainer/Label").text
	if node.get_connection():
		connection_input_button.select(connection_input_button.get_item_id(connection_button_list.find(node.get_connection().name)))
	else:
		connection_input_button.select(-1)
func _on_node_deselected(_node):
	selected_widget = null
	side_bar.visible = false
	
func _on_option_button_item_selected(index):
	var new_connection = node_editor.get_node(connection_input_button.get_item_text(index))
	selected_widget.set_connection(new_connection)
	connections[new_connection] = selected_widget

func _on_line_edit_text_submitted(new_text):
#	Set name of widget
	selected_widget.set_item_name(new_text)

func _on_color_picker_button_color_changed(color):
#	Set colour of widget
	if selected_widget:
		print(selected_widget.get_theme_stylebox("frame").duplicate())
		var new_theme = load("res://Styles/Slider.tres")
		new_theme.set_bg_color(color)
		selected_widget.add_theme_stylebox_override("frame",new_theme.duplicate())
		
		selected_widget.add_theme_stylebox_override("selected_frame",new_theme.duplicate())
	#	selected_widget.get_theme().add_theme_color_override()

func _on_external_input_pressed():
#	Set input mode to listen, the next action from any configured input will be set as the connection
	input_mode = "listen"

func _on_tab_container_tab_clicked(tab):
	pass

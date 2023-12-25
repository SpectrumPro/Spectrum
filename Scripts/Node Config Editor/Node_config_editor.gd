extends TabContainer

@onready var name_input = self.get_node("Editor/PanelContainer/VBoxContainer/VSplitContainer/VBoxContainer/Name Input")
@onready var template_node: GraphNode = self.get_node("Editor/Control/TemplateNode")
@onready var list: ItemList = self.get_node("Editor/PanelContainer/VBoxContainer/VSplitContainer/VBoxContainer/List")
@onready var row_settings = self.get_node("Editor/PanelContainer/VBoxContainer/VSplitContainer/ScrollContainer/VBoxContainer/Row Settings")

@onready var input_option_dropdown = self.get_node("Editor/PanelContainer/VBoxContainer/VSplitContainer/ScrollContainer/VBoxContainer/Row Settings/Options/Input Option")
@onready var output_option_dropdown = self.get_node("Editor/PanelContainer/VBoxContainer/VSplitContainer/ScrollContainer/VBoxContainer/Row Settings/Options/Output Option")

@onready var input_name_field = self.get_node("Editor/PanelContainer/VBoxContainer/VSplitContainer/ScrollContainer/VBoxContainer/Row Settings/Names/Input Name")
@onready var output_name_field = self.get_node("Editor/PanelContainer/VBoxContainer/VSplitContainer/ScrollContainer/VBoxContainer/Row Settings/Names/Output Name")

@onready var input_color_button = self.get_node("Editor/PanelContainer/VBoxContainer/VSplitContainer/ScrollContainer/VBoxContainer/Row Settings/Colors/Input Color")
@onready var output_color_button = self.get_node("Editor/PanelContainer/VBoxContainer/VSplitContainer/ScrollContainer/VBoxContainer/Row Settings/Colors/Output Color")

@onready var input_visable_button = self.get_node("Editor/PanelContainer/VBoxContainer/VSplitContainer/ScrollContainer/VBoxContainer/Row Settings/Visibility/Input Visable")

@onready var input_slot_visable_button = self.get_node("Editor/PanelContainer/VBoxContainer/VSplitContainer/ScrollContainer/VBoxContainer/Row Settings/Slot Visibility/Input Slot Visable")
@onready var output_slot_visable_button = self.get_node("Editor/PanelContainer/VBoxContainer/VSplitContainer/ScrollContainer/VBoxContainer/Row Settings/Slot Visibility/Output Slot Visable")

var row_index = 0
var row_select_index = 0
var row_data = {}

var input_types = {
	"none": null,
	"value": [[SpinBox,"Row$1 Value"]],
	"dmx_value": [[SpinBox, "Row$1 Channel"], [SpinBox,"Row$1 Value"]],
	"text": [[LineEdit, "Row$1 Text"]],
	"custom": []
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_name_input_text_changed(new_text):
	template_node.title = new_text

func _on_new_row_pressed():
	var row_index = row_data.size()  # Get the current size as the row index
	list.add_item("Row " + str(row_index))
	
	row_data[row_index] = {
		"input": false,
		"output": false,
		"input_type": "none",
		"output_type": "none",
		"input_name":"",
		"output_name":"",
		"input_visable":false,
		"input_slot_visable":true,
		"output_slot_visable":true,
		"row_name":""
	}
	
	update_rows()

func _on_delete_row_pressed():
	var selected_items = list.get_selected_items()
	# Remove items in reverse order to avoid index issues
	for i in range(selected_items.size() - 1, -1, -1):
		row_data.erase(selected_items[i])
		list.remove_item(selected_items[i])
		#template_node.remove_child(template_node.get_child(selected_items[i]))
	update_rows()

func update_rows():
	template_node.clear_all_slots()
	for n in template_node.get_children():
		template_node.remove_child(n)
		n.queue_free()
	
	for index in row_data:
		var new_row = HBoxContainer.new()
		new_row.name = "row" + str(index)
		#new_row.set_h_size_flags(2)
		template_node.add_child(new_row)
		var current_row = template_node.get_node("row"+str(index))
		
		template_node.set_slot(index, row_data[index].input,0,Color.WHITE,row_data[index].output, 0, Color.WHITE)

		if row_data[index].input_name:
			var node_to_add = Label.new()
			node_to_add.text = row_data[index].input_name
			node_to_add.set_h_size_flags(3)
			current_row.add_child(node_to_add)
				
		if row_data[index].input_type != "none":
			if row_data[index].input_visable:
				for node_to_add in input_types[row_data[index].input_type]:
					var new_node = node_to_add[0].new()
					new_node.set_name(node_to_add[1].replace("$1", str(index)))
					if row_data[index].input_name:
						new_node.set_h_size_flags(2)
						new_node.set_h_size_flags(8)
					else:
						new_node.set_h_size_flags(3)
					current_row.add_child(new_node)
		
		if row_data[index].output_name:
			var node_to_add = Label.new()
			node_to_add.text = row_data[index].output_name
			node_to_add.set_h_size_flags(2)
			node_to_add.set_h_size_flags(8)
			current_row.add_child(node_to_add)
	

func _on_list_multi_selected(index, selected):
	row_select_index = index
	row_settings.visible = true

func _on_input_option_item_selected(index):
	row_data[row_select_index].input_type = input_types.keys()[index]
	input_name_field.text = ""
	row_data[row_select_index].input_name = ""
	update_rows()
	
func _on_output_option_item_selected(index):
	row_data[row_select_index].output_type = input_types.keys()[index]
	output_name_field.text = ""
	row_data[row_select_index].output_name = ""
	update_rows()

func _on_input_name_text_changed(new_text):
	row_data[row_select_index].input_name = new_text
	update_rows()

func _on_output_name_text_changed(new_text):
	row_data[row_select_index].output_name = new_text
	update_rows()

func _on_input_color_color_changed(color):
	pass # Replace with function body.

func _on_output_color_color_changed(color):
	pass # Replace with function body.

func _on_input_slot_visable_toggled(toggled_on):
	row_data[row_select_index].input = toggled_on
	update_rows()
	
func _on_output_slot_visable_toggled(toggled_on):
	row_data[row_select_index].output = toggled_on
	update_rows()
	
func _on_input_visable_toggled(toggled_on):
	row_data[row_select_index].input_visable = toggled_on
	update_rows()

func _on_output_visable_toggled(toggled_on):
	pass # Replace with function body.


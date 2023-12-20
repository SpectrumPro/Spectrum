extends GraphEdit

var initial_position = Vector2(40,40)
var widget_index = 0

var built_in_widgets = {

}
var widget_path = Globals.widget_path

var connected_widgets = {}
var selected_widgets = []

var outbound_queue = {}
# Called when the widget enters the scene tree for the first time.
func _ready():
	_add_menu_hbox_button("Add Widget", Globals.nodes.add_widget_popup.add_widget_button_clicked)
	_add_menu_hbox_button("Delete Widget", self.request_delete)
	_add_menu_hbox_button(Globals.icons.menue, self.show_settings_menu)
	
	
	self.get_menu_hbox().get_node(NodePath("@SpinBox@33")).value_changed.connect(set_global_values_snapping_distance)
	
	var access = DirAccess.open(widget_path)
	for widget_folder in access.get_directories():
		var manifest_file_path = widget_path + widget_folder + "/manifest.json"
		if access.file_exists(manifest_file_path):
			var manifest_file = FileAccess.open(manifest_file_path, FileAccess.READ)
			var manifest = JSON.parse_string(manifest_file.get_as_text())
			if manifest == null:
				Globals.show_popup([{"type":Globals.error.UNABLE_TO_LOAD_MANIFEST,"from":manifest_file_path}])
				return
			var verify_result = verify_manifest(manifest, manifest_file_path)
			if verify_result == []:
				Globals.nodes.add_widget_popup.add_item(manifest.metadata.name)
				built_in_widgets[manifest.uuid] = widget_path + widget_folder + "/"
			else:
				Globals.show_popup(verify_result)

func _add_menu_hbox_button(content, method):
	var button = Button.new()
	if content is Texture2D:
		button.icon = content
	else:
		button.text = content
	button.pressed.connect(method)
	self.get_menu_hbox().add_child(button)

func verify_manifest(manifest,from):
	var return_mgs = []

	if not manifest.has("manifest_version"):
		return_mgs.append({"type":Globals.error.MANIFEST_MISSING_MANIFEST_VERSION,"from":from})
	if not manifest.has("minimum_version"):
		return_mgs.append({"type":Globals.error.MANIFEST_MISSING_MINIMUM_VERSION,"from":from})
	if not manifest.has("version"):
		return_mgs.append({"type":Globals.error.MANIFEST_MISSING_VERSION,"from":from})
	if not manifest.has("widget"):
		return_mgs.append({"type":Globals.error.MANIFEST_MISSING_WIDGET,"from":from})
	if not manifest.has("uuid"):
		return_mgs.append({"type":Globals.error.MANIFEST_MISSING_UUID,"from":from})
		
	if not manifest.get("metadata",false).get("name",false):
		return_mgs.append({"type":Globals.error.MANIFEST_MISSING_METADATA,"from":from})
	
	return return_mgs


func request_delete(widget=null):
	if widget == null:
		for i in selected_widgets:
			i.close_request()
			
		selected_widgets = []


func _add_widget(widget_file_path, overrides = {"name":"", "title":"", "position_offset":[]}):
	print(widget_file_path, overrides)
	var manifest_file = FileAccess.open(widget_file_path + "manifest.json", FileAccess.READ)
	var manifest = JSON.parse_string(manifest_file.get_as_text())
	if manifest == null:
		Globals.show_popup([{"type":Globals.error.MISSING_widgetS,"from":widget_file_path}])
		return
	
	
	if load(widget_file_path + manifest.widget.scene) == null:
		Globals.show_popup([{"type":Globals.error.UNABLE_TO_LOAD_SCENE,"from":widget_file_path}])
		return false
	
	var widget_to_add = load(widget_file_path + manifest.widget.scene).instantiate()
	
	if widget_to_add.get_script() == null:
		var sciprt_to_add = load(widget_file_path + manifest.widget.script)
		if sciprt_to_add == null:
			Globals.show_popup([{"type":Globals.error.UNABLE_TO_LOAD_SCRIPT,"from":widget_file_path}])
			return
		widget_to_add.set_script(sciprt_to_add)
	
	widget_to_add.position_offset = (get_viewport().get_mouse_position() + self.scroll_offset) / self.zoom
	widget_to_add.name = widget_to_add.name + str(widget_index)
	if widget_to_add.get("title"):
		widget_to_add.title = widget_to_add.title + " #" + str(widget_index)
	widget_to_add.set_meta("widget_file_path", widget_file_path)
	
	if overrides["position_offset"]:
		print(overrides.position_offset)
		widget_to_add.position_offset = Vector2i(overrides.position_offset[0],overrides.position_offset[1])
	
	if overrides.get("values"):
		for key in overrides.values.keys():
			widget_to_add.get_widget(manifest.values[key].widget).set(manifest.values[key].content, overrides.values[key])
			print(manifest.values[key])
	
	self.add_child(widget_to_add)
	widget_index += 1
	

func _on_widget_list_item_clicked(index, _at_position, _mouse_button_index):
	_add_widget(built_in_widgets.values()[index])

func _on_widget_selected(widget):
	selected_widgets.append(widget)

func _on_widget_deselected(widget):
	selected_widgets.erase(widget)

func show_settings_menu():
	if selected_widgets:
		Globals.nodes.widget_settings_menu.visible = !Globals.nodes.widget_settings_menu.visible

func set_global_values_snapping_distance(value):
	Globals.values.snapping_distance = value
	print(value)

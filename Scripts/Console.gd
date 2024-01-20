extends GraphEdit

var initial_position = Vector2(40,40)
var widget_index = 0

var built_in_widgets = {

}
var widget_path = Globals.widget_path

var connected_widgets = {}
var selected_widgets = []
var copyed_widgets= []

var outbound_queue = {}

var center_button
# Called when the widget enters the scene tree for the first time.
func _ready():
	_add_menu_hbox_button("Add Widgets", Globals.nodes.add_widget_popup.add_widget_button_clicked.bind(Vector2(220,100)))
	_add_menu_hbox_button("Delete Widgets", self.request_delete)
	_add_menu_hbox_button(Globals.icons.menue, self.show_settings_menu)
	center_button = _add_menu_hbox_button(Globals.icons.center, self._center_view)
	
	self.get_menu_hbox().get_node(NodePath("@SpinBox@33")).value_changed.connect(set_global_values_snapping_distance)
	
	Globals.subscribe("edit_mode", edit_mode_toggled)
	
	load_widgets_from_file()
	
func load_widgets_from_file():
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
	return button
	
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
		widget_to_add.position_offset = Vector2i(overrides.position_offset[0],overrides.position_offset[1])
	
	if overrides.get("size"):
		widget_to_add.size = Vector2i(overrides.size[0],overrides.size[1])
	
	if overrides.get("values"):
		for key in overrides.values.keys():
			if manifest.values.get(key):
				widget_to_add.get_node(manifest.values[key].node).set(manifest.values[key].content, overrides.values[key].value)
			else:
				Globals.show_popup([{"type":Globals.error.WIDGET_LOAD_MANIFEST_ERROR,"from":widget_file_path}])
	self.add_child(widget_to_add)
	widget_index += 1
	

func _on_widget_list_item_clicked(index, _at_position, _mouse_button_index):
	_add_widget(built_in_widgets.values()[index])

func _on_widget_selected(widget):
	if Globals.values.edit_mode:
		selected_widgets.append(widget)
		widget.material = Globals.shaders.invert

func _on_widget_deselected(widget):
	if Globals.values.edit_mode:
		selected_widgets.erase(widget)
		widget.material = null
	

func show_settings_menu():
	Globals.nodes.widget_settings_menu.visible = !Globals.nodes.widget_settings_menu.visible

func set_global_values_snapping_distance(value):
	Globals.set_value("snapping_distance", value)


func _center_view():
	var positions = []
	var smallest_vector = []
	for child in get_children():
		if child is ItemList:
			pass
		else:
			positions.append(child.position_offset)
			
	if positions:
		smallest_vector = positions[0]
		
		for i in positions:
			if i.x < smallest_vector.x:
				smallest_vector.x = i.x
			if i.y < smallest_vector.y:
				smallest_vector.y = i.y

		var offset = smallest_vector * get_zoom()
		self.scroll_offset = offset + Vector2(-10, -60)


func _on_copy_nodes_request():
	copyed_widgets = selected_widgets.duplicate(true)
	print("copying")
	print(copyed_widgets)


func _on_paste_nodes_request():
	print("Pasting")
	print(copyed_widgets)
	for i in copyed_widgets:
		print(i)
		add_child(get_node(i))


func _on_duplicate_nodes_request():
	for i in selected_widgets:
		add_child(get_node(i))


func edit_mode_toggled(edit_mode):
	for node in get_menu_hbox().get_children():
		if node is Range:
			node.editable = edit_mode
		elif node is BaseButton:
			node.disabled = not edit_mode
		get_menu_hbox().get_node(NodePath(center_button.name)).disabled = mouse_default_cursor_shape
	if not edit_mode:
		print(self.get_theme())
		self.add_theme_color_override("selection_stroke",Color.TRANSPARENT)
		self.add_theme_color_override("selection_fill",Color.TRANSPARENT)
		for widget in selected_widgets:
			widget.material = null
	else:
		self.remove_theme_color_override("selection_stroke")
		self.remove_theme_color_override("selection_fill")
		for widget in selected_widgets:
			widget.material = Globals.shaders.invert
		
func _on_popup_request(at_position):
	Globals.nodes.add_widget_popup.add_widget_button_clicked(at_position)

extends Window

@onready var restart_warning = get_node("TabContainer/General/Restart Warning")
@onready var ui_scale_input  = get_node("TabContainer/General/General/HBoxContainer/UI Scale")
var config = ConfigFile.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	config.load("user://spectrum.cfg")
	var scale_factor = config.get_value("Display", "content_scale_factor")
	self.set_content_scale_factor(scale_factor)
	get_tree().root.set_content_scale_factor(scale_factor)
	#get_parent().get_node("Node Config Editor").set_content_scale_factor(config.get_value("Display", "content_scale_factor"))
	get_parent().get_node("Popups").set_content_scale_factor(scale_factor)
	#get_parent().get_node("FileDialog").set_content_scale_factor(scale_factor)	
	ui_scale_input.set_value_no_signal(scale_factor)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_settings_pressed():
	self.popup()


func _on_close_requested(): 
	self.hide()

func save():
	config.save("user://spectrum.cfg")

func _on_ui_scale_value_changed(value):
	config.set_value("Display", "content_scale_factor", value)
	var scale_factor = value
	self.set_content_scale_factor(scale_factor)
	get_tree().root.set_content_scale_factor(scale_factor)
	#get_parent().get_node("Node Config Editor").set_content_scale_factor(config.get_value("Display", "content_scale_factor"))
	get_parent().get_node("Popups").set_content_scale_factor(scale_factor)
	#get_parent().get_node("FileDialog").set_content_scale_factor(scale_factor)
	
	save()


func _on_v_sync_toggled(toggled_on):

	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	print(DisplayServer.window_get_vsync_mode())

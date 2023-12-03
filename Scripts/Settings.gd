extends Window

@onready var restart_warning = get_node("TabContainer/General/Restart Warning")
@onready var ui_scale_input  = get_node("TabContainer/General/General/HBoxContainer/UI Scale")
var config = ConfigFile.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	config.load("user://spectrum.cfg")
	get_tree().root.set_content_scale_factor(config.get_value("Display", "content_scale_factor"))
	ui_scale_input.value = get_tree().root.content_scale_factor

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
	get_tree().root.set_content_scale_factor(value)
	save()

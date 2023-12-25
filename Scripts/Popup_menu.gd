extends MenuButton


# Called when the node enters the scene tree for the first time.
func _ready():
	get_popup().index_pressed.connect(_item_clicked)

func _item_clicked(index):
	match index:
		0:
			pass
		1:
			pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

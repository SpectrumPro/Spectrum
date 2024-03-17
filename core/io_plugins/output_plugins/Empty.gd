class_name EmptyOutput extends DataIOPlugin

var exposed_values = []

func _init():
	self.set_type("output")
	self.name = "Empty Output"
	
	super._init()

func serialize() -> Dictionary:
	return {
		"type":"Empty"
	}

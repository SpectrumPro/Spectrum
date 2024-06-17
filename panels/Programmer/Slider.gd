extends VSlider

@export_node_path("SpinBox") var spin_box: NodePath

func _ready() -> void:
	value_changed.connect(_on_value_changed)
	get_node(spin_box).value_changed.connect(_on_spin_box_value_changed)


func _on_value_changed(value: float) -> void:
	get_node(spin_box).value = value


func _on_spin_box_value_changed(p_value: float) -> void:
	value = p_value



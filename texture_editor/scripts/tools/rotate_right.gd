extends Button


func _process(_delta: float) -> void:
	if $".".button_pressed:
		%ModelViewer.rotate_model(Vector2(-3, 0))

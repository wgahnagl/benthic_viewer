extends Button


func _ready() -> void:
	$".".connect("pressed", _on_button_press)


func _on_button_press():
	%FaceGuide.visible = !%FaceGuide.visible

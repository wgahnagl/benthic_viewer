extends Button


func _ready():
	$".".connect("pressed", _on_button_press)


func _on_button_press():
	%Node3D.rotation = Vector3(0, 0, 0)

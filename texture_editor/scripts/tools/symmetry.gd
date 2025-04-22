extends Button


func _ready():
	$".".connect("pressed", _on_button_press)


func _on_button_press():
	Globals.MIRROR_ENABLED = !Globals.MIRROR_ENABLED

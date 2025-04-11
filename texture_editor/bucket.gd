extends Button


func _ready():
	$".".connect("pressed", _on_button_press)

func _on_button_press():
	Globals.BUCKET_ENABLED = true
	$"../Pen".button_pressed = false
	$".".button_pressed = true

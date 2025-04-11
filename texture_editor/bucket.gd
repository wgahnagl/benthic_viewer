extends Button


func _ready():
	$".".connect("pressed", _on_button_press)

func _on_button_press():
	Globals.BUCKET_ENABLED = true
	Globals.LINE_ENABLED = false
	$"../Pen".button_pressed = false
	$"../Line".button_pressed = false
	$".".button_pressed = true

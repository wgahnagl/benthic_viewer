extends Button


func _ready():
	$".".connect("pressed", _on_button_press)

func _on_button_press():
	if Globals.CURRENT_COLOR == -1: 
		Globals.CURRENT_COLOR = Globals.LAST_COLOR
	Globals.BUCKET_ENABLED = false
	Globals.LINE_ENABLED = false
	$"../Bucket".button_pressed = false
	$"../Eraser".button_pressed = false
	$"../Line".button_pressed = false
	$".".button_pressed = true

extends Button


func _ready():
	$".".connect("pressed", _on_button_press)

func _on_button_press():
	Globals.LINE_ENABLED = true
	Globals.BUCKET_ENABLED = false
	$"../Pen".button_pressed = false
	$"../Bucket".button_pressed = false
	$".".button_pressed = true

extends Button

func _ready():
	$".".connect("pressed", _on_button_press)

func _on_button_press():
	Globals.BUCKET_ENABLED = false
	Globals.LINE_ENABLED = false
	Globals.RECTANGLE_ENABLED = true
	Globals.CIRCLE_ENABLED = false
	$"../Bucket".button_pressed = false
	$"../Line".button_pressed = false
	$"../Circle Tool".button_pressed = false
	$".".button_pressed = true

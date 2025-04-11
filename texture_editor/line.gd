extends Button


func _ready():
	$".".connect("pressed", _on_button_press)

func _on_button_press():
	Globals.BUCKET_ENABLED = false
	Globals.LINE_ENABLED = true
	Globals.RECTANGLE_ENABLED = false
	Globals.CIRCLE_ENABLED = false
	Globals.STAMP_1_ENABLED =  false
	Globals.STAMP_2_ENABLED = false
	$"../Bucket".button_pressed = false
	$"../Line".button_pressed = false
	$"../Circle Tool".button_pressed = false
	$"../Rectangle Tool".button_pressed = false
	%Stamp1.button_pressed = false
	$".".button_pressed = true

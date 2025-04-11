extends Button


func _ready():
	$".".connect("pressed", _on_button_press)

func _on_button_press():
	if Globals.CURRENT_COLOR == -1: 
		Globals.CURRENT_COLOR = Globals.LAST_COLOR
		%Eraser.button_pressed = false
		$"../Pen".button_pressed = true
	else: 
		Globals.LAST_COLOR = Globals.CURRENT_COLOR
		Globals.CURRENT_COLOR = -1
		$"../Pen".button_pressed = false

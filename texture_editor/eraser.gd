extends Button


func _ready():
	$".".connect("pressed", _on_button_press)

func _on_button_press():
	Globals.LAST_COLOR = Globals.CURRENT_COLOR
	Globals.CURRENT_COLOR = -1

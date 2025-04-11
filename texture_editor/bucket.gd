extends Button


func _ready():
	$".".connect("pressed", _on_button_press)

func _on_button_press():
	Globals.BUCKET_ENABLED = true
	print(Globals.BUCKET_ENABLED)

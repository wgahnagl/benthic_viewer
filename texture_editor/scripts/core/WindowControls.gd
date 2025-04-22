extends Control


func _ready() -> void:
	%MinimizeButton.connect("pressed", _on_minimize_button_pressed)
	%ExitButton.connect("pressed", _on_exit_button_pressed)


func _on_exit_button_pressed():
	get_tree().quit()


func _on_minimize_button_pressed():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

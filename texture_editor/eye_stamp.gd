extends Button

func _ready() -> void:
	var popup = $".".get_popup()
	var texture1 = load("res://themes/Palettes/palette1.svg")
	popup.add_icon_item(texture1, "")
	popup.transparent_bg = true

func _on_pressed() -> void:
	var popup = $".".get_popup()
	var button_position = $".".global_position
	var button_size = $".".size
	popup.position = Vector2(button_position.x + button_size.x, button_position.y)
	popup.popup()

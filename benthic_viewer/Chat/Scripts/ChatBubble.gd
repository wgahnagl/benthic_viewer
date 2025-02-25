extends Control

class_name ChatBubble

@export var chat_panel : PanelContainer
@export var message_label  : Label

func set_message(username: String, message: String, chat_from_self: bool) -> void :
	if chat_from_self :
		var style_box = chat_panel.get_theme_stylebox("panel").duplicate() # Duplicate to avoid modifying the default theme
		style_box.bg_color = Color(0.1, 0.1, 0.1)  # Set new color
		chat_panel.add_theme_stylebox_override("panel", style_box)
	message_label.text = username + " : " + message

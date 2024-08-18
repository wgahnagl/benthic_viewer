extends Button

const loading_scene_path = "res://loading_screen.tscn"
@onready var metaverse_session = get_tree().root.get_node("MetaverseSession") 

func _on_pressed() -> void:
	var firstname = $"../firstname".text
	var lastname = $"../lastname".text
	var password = $"../password".text
	var grid = $"../grid".text
	metaverse_session.set_login_values(firstname, lastname, password, grid)
	metaverse_session.switch_to_scene("res://loading_screen.tscn")

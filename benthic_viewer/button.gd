extends Button 
@onready var metaverse_session = get_tree().root.get_node("MetaverseSession") 

func _on_pressed() -> void:
	var firstname = $"../firstname".text
	var lastname = $"../lastname".text
	var password = $"../password".text
	var grid = $"../grid".text
	metaverse_session.login(firstname, lastname, password, grid)

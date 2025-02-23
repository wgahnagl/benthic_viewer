extends Button 
@onready var metaverse_session = get_tree().root.get_node("MetaverseSession") 

func _on_pressed() -> void:
	var error = get_tree().root.find_child("Error", true, false)
	error.hide()

	var firstname = $"../firstname".text
	var lastname = $"../lastname".text
	var password = $"../password".text
	var grid = $"../grid".text
	var loading = get_tree().root.find_child("Loading", true, false)
	loading.show()
	metaverse_session.login(firstname, lastname, password, grid)

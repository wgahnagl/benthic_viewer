extends Button


func _on_pressed() -> void:
	var firstname = $"../firstname".text
	var lastname = $"../lastname".text
	var password = $"../Password".text
	var grid = $"../Grid".text
	var metaverse_session = $"../../.."
	metaverse_session.init_session(firstname, lastname, grid, password)

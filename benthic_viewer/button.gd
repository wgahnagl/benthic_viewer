extends Button

const loading_scene_path = "res://loading_screen.tscn"
@onready var metaverse_session = get_tree().root.get_node("MetaverseSession") 

func _on_pressed() -> void:
	
	var loading = $"../../../Loading"
	var errbox = $"../../../ErrorBox"
	loading.visible = true
	errbox.visible = false
	
	
	# this makes it so that it has time to show the load
	await get_tree().create_timer(.1).timeout
	
	var firstname = $"../firstname".text
	var lastname = $"../lastname".text
	var password = $"../password".text
	var grid = $"../grid".text
	metaverse_session.init_session(firstname, lastname, grid, password)
	loading.visible = false
	
	var login_status = metaverse_session.get_login_status()
	if login_status[0] : 
		metaverse_session.switch_to_scene("res://chat.tscn")
	else: 
		errbox.visible = true
		$"../../../ErrorBox/Error".text = login_status[1]

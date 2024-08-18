extends MetaverseSession

var firstname = ""
var lastname = ""
var password = ""
var grid = ""

var loginSuccess = false
var loginError = ""
func get_login_values() -> Array:
	return [firstname, lastname, password, grid]

func get_login_status() -> Array: 
	return [loginSuccess, loginError]

func _ready() -> void:
	connect("client_update", _on_client_update)
	switch_to_scene("res://login.tscn")

func _process(delta: float) -> void: 
	check_stream() 

func switch_to_scene(scene_path: String) -> void:
	# Remove the current scene if it exists
	if has_node("CurrentScene"):
		var current_scene = get_node("CurrentScene")
		remove_child(current_scene)
		current_scene.queue_free()  
		
	var scene_resource = load(scene_path) 
	if scene_resource:
		var new_scene = scene_resource.instantiate()
		add_child(new_scene)
		new_scene.name = "CurrentScene"
	else:
		print("Failed to load scene from path: ")


func _on_client_update(message_type: String, message: String):
	match message_type:
		"String":
			print("Received String data: ", message)
		"Packet":
			print("Received Packet data: ", message)
		"LoginProgress":
			print("Login progress: ", message)
			if message == "100":
				loginSuccess = true
		"Error":
			print("Error received: ", message)
			loginError = message
		"Chat": 
			print("Chat received: ", message)
		_:
			print("Unknown message type")

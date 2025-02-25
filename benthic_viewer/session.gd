extends MetaverseSession 
@onready var metaverse_session = get_tree().root.get_node("MetaverseSession") 

# on ready, set the current scene to login
func _ready() -> void:
		switch_to_scene("res://Login/login.tscn")
		
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

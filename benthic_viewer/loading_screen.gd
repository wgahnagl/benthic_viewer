extends Control
@onready var metaverse_session = get_tree().root.get_node("MetaverseSession") 
signal initialization_complete

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emit_signal("initialization_complete")

func _on_initialization_complete() -> void:
	var login = metaverse_session.get_login_values()
	metaverse_session.init_session(login[0], login[1], login[2], login[3])
	metaverse_session.switch_to_scene("res://chat.tscn")

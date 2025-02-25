extends Button
@onready var metaverse_session = get_tree().root.get_node("MetaverseSession") 
@onready var chat = get_tree().root.get_node("MetaverseSession/Chat") 

func _on_pressed() -> void:
	chat.send_message()

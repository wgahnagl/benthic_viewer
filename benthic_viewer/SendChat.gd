extends Button
@onready var metaverse_session = get_tree().root.get_node("MetaverseSession") 

func _on_pressed() -> void:
	var chat = $"../ChatBox".text
	metaverse_session.send_chat(chat)

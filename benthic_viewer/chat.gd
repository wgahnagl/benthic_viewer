extends Control
@onready var metaverse_session = get_tree().root.get_node("MetaverseSession") 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	metaverse_session.connect("chat_from_simulator", _on_chat_from_simulator)

func _on_chat_from_simulator(user, message, chat_from_self) -> void:
	var chat_ui = $ScrollContainer/ChatContainer
	var label = Label.new()
	if chat_from_self:
		label.text = "You : " + message
	else:
		label.text = user + " : " + message
	chat_ui.add_child(label)
	chat_ui.move_child(label, 0)

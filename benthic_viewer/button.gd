extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	var firstname = $"../firstname".text
	var lastname = $"../lastname".text
	var password = $"../Password".text
	var grid = $"../Grid".text
	var metaverse_session = $"../../.."
	metaverse_session.init_session(firstname, lastname, grid, password)

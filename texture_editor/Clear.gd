extends Button

@onready var clear_image_script = $"../../PanelContainer/PixelEditor" # Ensure the correct node path
func _ready():
	connect("pressed", Callable(self, "clear_image"))

func clear_image() -> void:
	clear_image_script.initialize_canvas()

extends Button

class_name SaveButton
@export var filename: String

@onready var save_image_script = $"../../PanelContainer/PixelEditor" # Ensure the correct node path
func _ready():
	connect("pressed", Callable(self, "save_image"))

func save_image() -> void:
	save_image_script.save_image("user://"+filename+".png")
	print("saved as: " + filename + ".png")

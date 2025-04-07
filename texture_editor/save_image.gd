extends Button

class_name SaveButton
@export var filename: String

@onready var save_image_script = $"../../PanelContainer/PixelEditor" # Ensure the correct node path
func _ready():
	print("SaveButton initialized with filename:", filename)
	connect("pressed", Callable(self, "save_image"))

	
func save_image() -> void:
	print("Pressed button instance:", self, "with filename:", filename)
	print(filename)
	save_image_script.save_image("user://"+filename+".png")
	print("Image saved to user://"+filename+".png")

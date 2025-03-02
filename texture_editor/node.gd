extends Node2D

var pixel_editor_scene = preload("res://Canvas.tscn") # Adjust the path as needed
var pixel_editor_instance

func _ready():
	pixel_editor_instance = pixel_editor_scene.instance()
	pixel_editor_instance.canvas_size = Vector2(64, 64) # Set custom canvas size if needed
	add_child(pixel_editor_instance)

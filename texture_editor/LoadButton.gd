extends Button

@onready var file_dialog =  $"../../../../../../FileDialog"
@onready var save_image_script = $"../../../../Canvases/VBoxContainer/VBoxContainer/PanelContainer/PixelEditor"

func _on_pressed() -> void:
	file_dialog.popup_centered()

func _on_file_selected(path: String) -> void:
	save_image_script.load_image(path)
	

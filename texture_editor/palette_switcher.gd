extends Button

signal palette_selected(id)

func _ready() -> void:
	var popup = $".".get_popup()	
	var svg = load("res://themes/palettes/palettes.svg")
	var palettes = svg.get_image()
	
	palettes.resize(195, 160) # make divisible by 5 to avoid graphical errors
	var num_palettes := 5 
	var swatch_height: int = palettes.get_height() / num_palettes
	var swatch_width: int = palettes.get_width()
	
	for i in range(num_palettes):
		var rect := Rect2(0, i * swatch_height , swatch_width, swatch_height)
		print(rect)
		
		var cropped := Image.create(swatch_width, swatch_height, false, Image.FORMAT_RGB8)
		cropped.blit_rect(palettes, rect, Vector2.ZERO)
		
		var texture := ImageTexture.create_from_image(cropped)
		popup.add_icon_item(texture, "")
		
	popup.transparent_bg = true
	popup.connect("id_pressed", set_palette)

func set_palette( id ): 
	emit_signal("palette_selected", id)

func _on_pressed() -> void:
	var popup = $".".get_popup()
	var button_position = $".".global_position
	var button_size = $".".size
	popup.position = Vector2(button_position.x + button_size.x, button_position.y)
	popup.popup()

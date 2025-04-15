extends Button

signal palette_selected(id)

func _ready() -> void:
	var popup = $".".get_popup()
	var svg = load("res://themes/palettes/palettes.svg")
	var palettes = svg.get_image()

	palettes.resize(195, 160)  # make divisible by 5 to avoid graphical errors
	var num_palettes := 5
	var swatch_height: int = palettes.get_height() / num_palettes
	var swatch_width: int = palettes.get_width()

	for i in range(num_palettes):
		var rect := Rect2(0, i * swatch_height, swatch_width, swatch_height)
		var cropped := Image.create(swatch_width, swatch_height, false, Image.FORMAT_RGB8)
		cropped.blit_rect(palettes, rect, Vector2.ZERO)

		var texture := ImageTexture.create_from_image(cropped)
		popup.add_icon_item(texture, "")

	popup.transparent_bg = true
	popup.connect("id_pressed", set_palette)


func set_palette(id):
	Globals.set_button_color(%CurrentColor, id, Globals.CURRENT_COLOR)
	emit_signal("palette_selected", id)


func _on_pressed() -> void:
	var popup = $".".get_popup()
	var button_position = $".".global_position
	var button_size = $".".size
	popup.position = Vector2(button_position.x + button_size.x, button_position.y)
	popup.popup()


func update_palette(
	face_image: Image, face_texture: Texture, base_image: Image, base_texture: Texture, id: int
):
	for y in range(Globals.DRAWING.size()):
		var row = Globals.DRAWING[y]
		for x in range(row.size()):
			var color_id = row[x]
			var p = Vector2(x + Globals.DRAW_AREA_OFFSET.x, y + Globals.DRAW_AREA_OFFSET.y)
			if color_id < 0:
				face_image.set_pixelv(p, Color(1, 1, 1, 0))
			else:
				face_image.set_pixelv(p, Globals.PALETTES[id][color_id])
	base_image.fill(Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_BACKGROUND_COLOR])
	base_texture.update(base_image)
	face_texture.update(face_image)

extends Button

signal palette_selected(id)


func _ready() -> void:
	var popup = $".".get_popup()

	var width = 160
	var height = 30

	for palette in Globals.PALETTES:
		var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
		var color_width: float = width / palette.size()
		for i in palette.size():
			var start_x := int(i * color_width)
			var end_x := int((i + 1) * color_width)
			for x in range(start_x, end_x):
				for y in height:
					image.set_pixel(x, y, palette[i])
		var texture := ImageTexture.create_from_image(image)
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
	face_image: Image,
	face_texture: Texture,
	base_image: Image,
	base_texture: Texture,
	pattern_image: Image,
	pattern_texture: Texture,
	id: int
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

	%PatternColor.change_pattern_color(pattern_image, pattern_texture)

	base_image.fill(Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_BACKGROUND_COLOR])
	base_texture.update(base_image)
	face_texture.update(face_image)

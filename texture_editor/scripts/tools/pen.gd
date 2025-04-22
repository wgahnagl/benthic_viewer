extends Button


func _ready():
	$".".connect("pressed", _on_button_press)


func _on_button_press():
	if Globals.CURRENT_COLOR == -1:
		Globals.CURRENT_COLOR = Globals.LAST_COLOR
	Globals.BUCKET_ENABLED = false
	Globals.LINE_ENABLED = false
	Globals.STAMP_1_ENABLED = false
	Globals.STAMP_2_ENABLED = false
	Globals.RECTANGLE_ENABLED = false
	Globals.CIRCLE_ENABLED = false

	$"../Bucket".button_pressed = false
	$"../Eraser".button_pressed = false
	$"../Circle Tool".button_pressed = false
	$"../Rectangle Tool".button_pressed = false
	$"../Stamp1".button_pressed = false
	$"../Stamp2".button_pressed = false
	$"../Line".button_pressed = false
	$".".button_pressed = true


func draw_at(image: Image, texture: Texture, pos: Vector2, preview_image = false):
	var width = image.get_width()
	var height = image.get_height()
	var size := int(Globals.CURRENT_DRAW_SIZE)
	for y in range(-size, size):
		for x in range(-size, size):
			var p = pos + Vector2(x, y)
			if (
				Globals.DRAW_AREA.has_point(p)
				and p.x >= 0
				and p.y >= 0
				and p.x < width
				and p.y < height
			):
				var local_pos = p - Globals.DRAW_AREA_OFFSET
				if !preview_image:
					Globals.DRAWING[local_pos.y][local_pos.x] = Globals.CURRENT_COLOR
				if Globals.CURRENT_COLOR < 0:
					image.set_pixelv(p, Color(1, 1, 1, 0))
				else:
					image.set_pixelv(
						p, Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR]
					)
				if Globals.MIRROR_ENABLED:
					var mirror_x = (
						Globals.DRAW_AREA_OFFSET.x * 2 + Globals.DRAW_AREA_SIZE.x - p.x - 1
					)
					var mirror_pos = Vector2(mirror_x, p.y)
					if mirror_pos.x >= 0 and mirror_pos.x < width:
						var mirror_local_pos = mirror_pos - Globals.DRAW_AREA_OFFSET
						if !preview_image:
							Globals.DRAWING[mirror_local_pos.y][mirror_local_pos.x] = (
								Globals.CURRENT_COLOR
							)
						if Globals.CURRENT_COLOR < 0:
							image.set_pixelv(mirror_pos, Color(1, 1, 1, 0))
						else:
							image.set_pixelv(
								mirror_pos,
								Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR]
							)
	texture.update(image)


func draw_between(image: Image, texture: Texture, start_pos: Vector2, end_pos: Vector2):
	var num_steps = max(1, int(start_pos.distance_to(end_pos)))
	for step in range(num_steps):
		var lerp_pos = start_pos.lerp(end_pos, step / float(num_steps))
		draw_at(image, texture, lerp_pos)

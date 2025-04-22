extends Button


func _ready():
	$".".connect("pressed", _on_button_press)


func _on_button_press():
	Globals.BUCKET_ENABLED = false
	Globals.LINE_ENABLED = false
	Globals.RECTANGLE_ENABLED = false
	Globals.CIRCLE_ENABLED = true
	Globals.STAMP_1_ENABLED = false
	Globals.STAMP_2_ENABLED = false
	$"../Bucket".button_pressed = false
	$"../Line".button_pressed = false
	$"../Circle Tool".button_pressed = false
	$"../Rectangle Tool".button_pressed = false
	%Stamp1.button_pressed = false
	%Stamp2.button_pressed = false
	$".".button_pressed = true


func draw_circle_on_canvas(image: Image, center: Vector2, radius: int):
	var width = image.get_width()
	var height = image.get_height()

	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			var distance = (x - center.x) * (x - center.x) + (y - center.y) * (y - center.y)
			if distance <= radius * radius:
				var p = Vector2(x, y)
				if (
					Globals.DRAW_AREA.has_point(p)
					and p.x >= 0
					and p.y >= 0
					and p.x < width
					and p.y < height
				):
					var local_pos = p - Globals.DRAW_AREA_OFFSET
					Globals.DRAWING[local_pos.y][local_pos.x] = Globals.CURRENT_COLOR
					if Globals.CURRENT_COLOR < 0:
						image.set_pixelv(p, Color(1, 1, 1, 0))  # Transparent color
					else:
						image.set_pixelv(
							p, Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR]
						)

extends Button


func _ready():
	$".".connect("pressed", _on_button_press)


func _on_button_press():
	Globals.BUCKET_ENABLED = false
	Globals.LINE_ENABLED = false
	Globals.RECTANGLE_ENABLED = false
	Globals.CIRCLE_ENABLED = false
	Globals.STAMP_1_ENABLED = true
	Globals.STAMP_2_ENABLED = false
	$"../Bucket".button_pressed = false
	$"../Line".button_pressed = false
	$"../Circle Tool".button_pressed = false
	$"../Rectangle Tool".button_pressed = false
	%Stamp1.button_pressed = false
	$".".button_pressed = true


func draw_stamp_on_canvas(image: Image, stamp: Image, pos: Vector2, preview = false):
	var img_width = image.get_width()
	var img_height = image.get_height()
	var stamp_width = stamp.get_width()
	var stamp_height = stamp.get_height()

	for y in range(stamp_height):
		for x in range(stamp_width):
			var canvas_pos = pos + Vector2(x, y)
			if (
				Globals.DRAW_AREA.has_point(canvas_pos)
				and canvas_pos.x >= 0
				and canvas_pos.y >= 0
				and canvas_pos.x < img_width
				and canvas_pos.y < img_height
			):
				var local_pos = canvas_pos - Globals.DRAW_AREA_OFFSET
				if stamp.get_pixel(x, y).a > 0.0:
					if Globals.CURRENT_COLOR == -1:
						image.set_pixelv(canvas_pos, Color(0, 0, 0, 0))
					else:
						image.set_pixelv(
							canvas_pos,
							Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR]
						)
					if preview:
						Globals.DRAWING[local_pos.y][local_pos.x] = Globals.CURRENT_COLOR

extends Button


func _ready():
	$".".connect("pressed", _on_button_press)


func _on_button_press():
	Globals.BUCKET_ENABLED = false
	Globals.LINE_ENABLED = false
	Globals.RECTANGLE_ENABLED = true
	Globals.CIRCLE_ENABLED = false
	Globals.STAMP_1_ENABLED = false
	Globals.STAMP_2_ENABLED = false
	$"../Bucket".button_pressed = false
	$"../Line".button_pressed = false
	$"../Circle Tool".button_pressed = false
	$"../Rectangle Tool".button_pressed = false
	%Stamp1.button_pressed = false
	%Stamp2.button_pressed = false

	$".".button_pressed = true


func draw_rectangle_on_canvas(image: Image, start_pos: Vector2, width: int, height: int):
	var img_width = image.get_width()
	var img_height = image.get_height()

	var top_left = start_pos
	var bottom_right = start_pos + Vector2(width, height)

	# Loop through the area inside the rectangle
	for y in range(min(top_left.y, bottom_right.y), max(top_left.y, bottom_right.y) + 1):
		for x in range(min(top_left.x, bottom_right.x), max(top_left.x, bottom_right.x) + 1):
			if (
				Globals.DRAW_AREA.has_point(Vector2(x, y))
				and x >= 0
				and y >= 0
				and x < img_width
				and y < img_height
			):
				var p = Vector2(x, y)
				var local_pos = p - Globals.DRAW_AREA_OFFSET
				Globals.DRAWING[local_pos.y][local_pos.x] = Globals.CURRENT_COLOR
				if Globals.CURRENT_COLOR < 0:
					image.set_pixelv(p, Color(1, 1, 1, 0))  # Transparent color
				else:
					image.set_pixelv(
						p, Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR]
					)

extends Button


func _ready():
	$".".connect("pressed", _on_button_press)

func _on_button_press():
	Globals.BUCKET_ENABLED = true
	Globals.LINE_ENABLED = false
	Globals.RECTANGLE_ENABLED = false
	Globals.CIRCLE_ENABLED = false
	Globals.STAMP_1_ENABLED =  false
	Globals.STAMP_2_ENABLED = false
	$"../Bucket".button_pressed = false
	$"../Line".button_pressed = false
	$"../Circle Tool".button_pressed = false
	$"../Rectangle Tool".button_pressed = false
	%Stamp1.button_pressed = false
	%Stamp2.button_pressed = false
	$".".button_pressed = true

func bucket_fill(image: Image, texture: Texture, pos: Vector2):
	var width = image.get_width()
	var height = image.get_height()
	if pos.x < 0 or pos.y < 0 or pos.x >= width or pos.y >= height:
		return
	var target_color = image.get_pixelv(pos)
	var new_color: Color = Color(1, 1, 1, 0) if Globals.CURRENT_COLOR == -1 else Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR]
	if target_color == new_color:
		return
	var stack: Array[Vector2] = [pos]
	while stack.size() > 0:
		var p = stack.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= width or p.y >= height:
			continue
		if not Globals.DRAW_AREA.has_point(p):
			continue
		var current_color = image.get_pixelv(p)
		if current_color != target_color:
			continue
		var local_pos = p - Globals.DRAW_AREA_OFFSET
		if Globals.CURRENT_COLOR < 0:
			image.set_pixelv(p, Color(1,1,1,0))
			Globals.DRAWING[local_pos.y][local_pos.x] = -1
		else:
			image.set_pixelv(p, new_color)
			Globals.DRAWING[local_pos.y][local_pos.x] = Globals.CURRENT_COLOR
		stack.append(p + Vector2(1, 0))
		stack.append(p + Vector2(-1, 0))
		stack.append(p + Vector2(0, 1))
		stack.append(p + Vector2(0, -1))
	texture.update(image)

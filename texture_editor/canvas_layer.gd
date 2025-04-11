extends Control

var face_image
var face_texture
var base_image 
var base_texture
var pattern_image 
var pattern_texture

var mirror_enabled := true 

var draw_area
var is_drawing = false
var previous_pos = Vector2()

var is_line_drawing := false
var line_start_pos: Vector2
var line_end_pos: Vector2

var is_circle_drawing = false
var circle_start_pos = Vector2()
var circle_radius = 0

var is_rectangle_drawing = false
var rectangle_start_pos = Vector2()
var rectangle_width = 0
var rectangle_height = 0

var stamp2_index = 0
var stamp2_image = load("res://themes/stamps/stamp2_"+str(stamp2_index)+".svg").get_image()

var undo_stack = []
var redo_stack = []

@export var draw_area_position : Vector2 = Vector2(250, 120)  
@export var draw_area_size : Vector2 = Vector2(200, 200)

@onready var texture_rect : TextureRect = %TextureRect
@onready var full_rect: TextureRect = $display

var grid = []

func _ready():
	face_image = Image.create(1500, 1500, false, Image.FORMAT_RGBA8)
	face_image.fill(Color(1, 1, 1, 0)) 
	
	texture_rect.set_position(-draw_area_position)
	face_texture = ImageTexture.create_from_image(face_image)
	texture_rect.texture = face_texture
	
	draw_area = Rect2(draw_area_position, draw_area_size)
	
	var at = AtlasTexture.new()
	at.atlas = face_texture
	at.region = Rect2(draw_area_position, draw_area_size)
	full_rect.texture = at 
	
	full_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	set_player_texture(face_texture)
	
	var palette_selector = %PaletteSwitcher
	palette_selector.connect("palette_selected", _on_palette_selected)
	
	var background_color = %BackgroundColors
	background_color.connect("pressed", _on_background_change)
	
	var clear = %Clear
	clear.connect("pressed", _on_clear)
	
	var undo = %Undo
	undo.connect("pressed", _on_undo)
	
	var redo = %Redo
	redo.connect("pressed", _on_redo)
	
	var stamp2 = %Stamp2
	stamp2.connect("stamp_selected", _on_stamp_2)
	
	var submit = %Submit
	submit.connect("pressed", save_texture)

	save_state()

func _on_stamp_2(i: int):
	Globals.STAMP_2_ENABLED = true
	stamp2_index = i
	stamp2_image = load("res://themes/stamps/stamp2_"+str(stamp2_index)+".svg").get_image()

func _on_clear():
	for y in range(Globals.DRAWING.size()):
		var row = Globals.DRAWING[y]
		for x in range(row.size()):
			var p = Vector2(x + draw_area_position.x, y + draw_area_position.y)
			Globals.DRAWING[x][y] = -1
			face_image.set_pixelv(p, Color(1,1,1,0))
	face_texture.update(face_image)
	save_state()
	
func _on_palette_selected(id):
	for y in range(Globals.DRAWING.size()):
		var row = Globals.DRAWING[y]
		for x in range(row.size()):
			var color_id = row[x]
			var p = Vector2(x + draw_area_position.x, y + draw_area_position.y)
			if color_id < 0: 
				face_image.set_pixelv(p, Color(1,1,1,0))
			else: 
				face_image.set_pixelv(p, Globals.PALETTES[id][color_id])
	base_image.fill(Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_BACKGROUND_COLOR])
	base_texture.update(base_image)
	face_texture.update(face_image)
	save_state()

func set_player_texture(new_texture: ImageTexture):
	base_image = Image.create(1500, 1500, false, Image.FORMAT_RGBA8)
	base_image.fill(Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_BACKGROUND_COLOR]) 
	base_texture = ImageTexture.create_from_image(base_image)
	
	pattern_image = Image.create(1500, 1500, false, Image.FORMAT_RGBA8)
	pattern_image.fill(Color(0, 0, 0, 0)) 
	pattern_texture = ImageTexture.create_from_image(pattern_image)
	
	var mesh_instance = %Player/CustomArmature/Skeleton3D/player 
	var kitty_ears = %Player/"CustomArmature/Skeleton3D/kitty ears"

	var shader_material = load("res://PlayerLayers.tres") as ShaderMaterial
	shader_material.set_shader_parameter("base_texture", base_texture)
	shader_material.set_shader_parameter("pattern_texture", pattern_texture)
	shader_material.set_shader_parameter("face_texture", new_texture)
	
	mesh_instance.set_surface_override_material(0, shader_material)
	kitty_ears.set_surface_override_material(0, shader_material)
		
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Z and (event.ctrl_pressed or event.meta_pressed):
			_on_undo()
		elif event.keycode == KEY_Y and (event.ctrl_pressed or event.meta_pressed):
			_on_redo()

	if event is InputEventMouseButton:
		if event.pressed:
			var local_pos = texture_rect.get_local_mouse_position()
			if draw_area.has_point(local_pos):
				if Globals.BUCKET_ENABLED:
					bucket_fill(local_pos)
				elif Globals.LINE_ENABLED: 
					is_line_drawing = true
					line_start_pos = local_pos  
					line_end_pos = local_pos
				elif Globals.CIRCLE_ENABLED: 
					is_circle_drawing = true
					circle_start_pos = local_pos
					circle_radius = 0  
				elif Globals.RECTANGLE_ENABLED:
					is_rectangle_drawing = true
					rectangle_start_pos = local_pos
					rectangle_width = 0  # Reset width on each press
					rectangle_height = 0  # Reset height on each press
				elif Globals.STAMP_1_ENABLED: 
					draw_stamp_on_canvas(face_image, Globals.STAMP1_IMAGE, local_pos)
					Globals.STAMP_1_ENABLED = false
					%Stamp1.button_pressed = false
					save_state()
				elif Globals.STAMP_2_ENABLED: 
					draw_stamp_on_canvas(face_image, stamp2_image, local_pos)
					Globals.STAMP_2_ENABLED = false
					%Stamp2.button_pressed = false
					save_state()
				else:
					is_drawing = true
					previous_pos = local_pos 
					draw_at(face_image, local_pos)
		else:
			if is_line_drawing:
				is_line_drawing = false
				draw_line_on_canvas(face_image, line_start_pos, line_end_pos)
				save_state()
			elif is_circle_drawing:
				is_circle_drawing = false
				draw_circle_on_canvas(face_image, circle_start_pos, circle_radius)
				face_texture.update(face_image)
				save_state()
			elif is_rectangle_drawing:
				is_rectangle_drawing = false
				draw_rectangle_on_canvas(face_image, rectangle_start_pos, rectangle_width, rectangle_height)  # Finalize the rectangle drawing
				face_texture.update(face_image)
				save_state()
			elif is_drawing:
				is_drawing = false
				save_state()
	var local_pos = texture_rect.get_local_mouse_position()
	if event is InputEventMouseMotion and draw_area.has_point(local_pos):
		if Globals.STAMP_1_ENABLED:
			var preview_image = undo_stack[-1][0].duplicate()
			draw_stamp_on_canvas(preview_image, Globals.STAMP1_IMAGE, local_pos)
			face_texture.update(preview_image)
		if Globals.STAMP_2_ENABLED:
			var preview_image = undo_stack[-1][0].duplicate()
			draw_stamp_on_canvas(preview_image, stamp2_image, local_pos)
			face_texture.update(preview_image)
		elif is_circle_drawing:
			circle_radius = int(circle_start_pos.distance_to(local_pos)) 
			var preview_image = undo_stack[-1][0].duplicate()
			draw_circle_on_canvas(preview_image, circle_start_pos, circle_radius)
			face_texture.update(preview_image)
		elif is_rectangle_drawing:
			rectangle_width = int(local_pos.x - rectangle_start_pos.x) 
			rectangle_height = int(local_pos.y - rectangle_start_pos.y)
			var preview_image = undo_stack[-1][0].duplicate()
			draw_rectangle_on_canvas(preview_image, rectangle_start_pos, rectangle_width, rectangle_height)
			face_texture.update(preview_image)
		elif is_line_drawing: 
			var preview_image = undo_stack[-1][0].duplicate()
			draw_line_on_canvas(preview_image, line_start_pos, line_end_pos)
			face_texture.update(preview_image)
			line_end_pos = local_pos
		elif is_drawing and draw_area.has_point(local_pos):
			draw_between(previous_pos, local_pos)
			previous_pos = local_pos

func draw_stamp_on_canvas(image: Image, stamp: Image, pos:Vector2):
	var img_width = image.get_width()
	var img_height = image.get_height()
	var stamp_width = stamp.get_width()
	var stamp_height = stamp.get_height()

	for y in range(stamp_height):
		for x in range(stamp_width):
			var canvas_pos = pos + Vector2(x, y)
			if draw_area.has_point(canvas_pos) and canvas_pos.x >= 0 and canvas_pos.y >= 0 and canvas_pos.x < img_width and canvas_pos.y < img_height:
				var local_pos = canvas_pos - draw_area_position
				if stamp.get_pixel(x,y).a > 0.0:
					image.set_pixelv(canvas_pos, Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR])
					if image == face_image:
						Globals.DRAWING[local_pos.y][local_pos.x] = Globals.CURRENT_COLOR
				
func draw_line_on_canvas(image: Image, start_pos: Vector2, end_pos: Vector2):
	var num_steps = int(start_pos.distance_to(end_pos))
	for step in range(num_steps):
		var lerp_pos = start_pos.lerp(end_pos, step / float(num_steps))
		draw_at(image, lerp_pos) 


func draw_at(image: Image, pos: Vector2):
	var width = image.get_width()
	var height = image.get_height()
	var preview_image = image != face_image
	for y in range(-Globals.CURRENT_BRUSH_SIZE, Globals.CURRENT_BRUSH_SIZE):
		for x in range(-Globals.CURRENT_BRUSH_SIZE, Globals.CURRENT_BRUSH_SIZE):
			var p = pos + Vector2(x, y)
			if draw_area.has_point(p) and p.x >= 0 and p.y >= 0 and p.x < width and p.y < height:
				var local_pos = p - draw_area_position
				
				if !preview_image:
					Globals.DRAWING[local_pos.y][local_pos.x] = Globals.CURRENT_COLOR  # Note the flip (y, x)
				
				if Globals.CURRENT_COLOR < 0:
					image.set_pixelv(p, Color(1,1,1,0))
				else:
					image.set_pixelv(p, Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR])
				
				if Globals.MIRROR_ENABLED:
					var mirror_x = draw_area_position.x * 2 + draw_area_size.x - p.x - 1
					var mirror_pos = Vector2(mirror_x, p.y)
					if mirror_pos.x >= 0 and mirror_pos.x < width:
						var mirror_local_pos = mirror_pos - draw_area_position
						if !preview_image:
							Globals.DRAWING[mirror_local_pos.y][mirror_local_pos.x] = Globals.CURRENT_COLOR
						
						if Globals.CURRENT_COLOR < 0:
							image.set_pixelv(mirror_pos, Color(1,1,1,0))
						else:
							image.set_pixelv(mirror_pos, Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR])
	face_texture.update(face_image)
	queue_redraw()

func draw_between(start_pos: Vector2, end_pos: Vector2):
	var num_steps = int(start_pos.distance_to(end_pos))
	for step in range(num_steps):
		var lerp_pos = start_pos.lerp(end_pos, step / float(num_steps))
		draw_at(face_image, lerp_pos) 

func _on_background_change():
	if Globals.CURRENT_COLOR >= 0:
		base_image.fill(Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR])
		base_texture.update(base_image)
		
func bucket_fill(pos: Vector2):
	var width = face_image.get_width()
	var height = face_image.get_height()
	if pos.x < 0 or pos.y < 0 or pos.x >= width or pos.y >= height:
		return
	var target_color = face_image.get_pixelv(pos)
	var new_color: Color = Color(1, 1, 1, 0) if Globals.CURRENT_COLOR == -1 else Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR]
	if target_color == new_color:
		return
	var stack: Array[Vector2] = [pos]
	while stack.size() > 0:
		var p = stack.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= width or p.y >= height:
			continue
		if not draw_area.has_point(p):
			continue
		var current_color = face_image.get_pixelv(p)
		if current_color != target_color:
			continue
		var local_pos = p - draw_area_position
		if Globals.CURRENT_COLOR < 0:
			face_image.set_pixelv(p, Color(1,1,1,0))
			Globals.DRAWING[local_pos.y][local_pos.x] = -1
		else:
			face_image.set_pixelv(p, new_color)
			Globals.DRAWING[local_pos.y][local_pos.x] = Globals.CURRENT_COLOR
		stack.append(p + Vector2(1, 0))
		stack.append(p + Vector2(-1, 0))
		stack.append(p + Vector2(0, 1))
		stack.append(p + Vector2(0, -1))
	face_texture.update(face_image)
	save_state()

func draw_circle_on_canvas(image: Image, center: Vector2, radius: int):
	var width = image.get_width()
	var height = image.get_height()
	
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			var distance = (x - center.x) * (x - center.x) + (y - center.y) * (y - center.y)
			if distance <= radius * radius:
				var p = Vector2(x, y)
				if draw_area.has_point(p) and p.x >= 0 and p.y >= 0 and p.x < width and p.y < height:
					var local_pos = p - draw_area_position
					Globals.DRAWING[local_pos.y][local_pos.x] = Globals.CURRENT_COLOR
					if Globals.CURRENT_COLOR < 0:
						image.set_pixelv(p, Color(1, 1, 1, 0))  # Transparent color
					else:
						image.set_pixelv(p, Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR])

func save_state():
	undo_stack.append([face_image.duplicate(), Globals.DRAWING.duplicate(true)])
	if undo_stack.size() > 10:
		undo_stack.pop_front() 
	redo_stack.clear()

func _on_undo():
	if undo_stack.size() > 1:
		var current_state = undo_stack.pop_back()
		redo_stack.append(current_state)
		var previous_state = undo_stack[-1]  
		face_image = previous_state[0].duplicate()
		Globals.DRAWING = previous_state[1].duplicate(true)
		face_texture.update(face_image)
		
func _on_redo():
	if redo_stack.size() > 0:
		var state = redo_stack.pop_back()
		face_image = state[0]
		Globals.DRAWING = state[1]
		face_texture.update(face_image)
		undo_stack.append([face_image.duplicate(), Globals.DRAWING.duplicate()])  # Save to undo stack

func draw_rectangle_on_canvas(image: Image, start_pos: Vector2, width: int, height: int):
	var img_width = face_image.get_width()
	var img_height = face_image.get_height()
	
	var top_left = start_pos
	var bottom_right = start_pos + Vector2(width, height)
	
	# Loop through the area inside the rectangle
	for y in range(min(top_left.y, bottom_right.y), max(top_left.y, bottom_right.y) + 1):
		for x in range(min(top_left.x, bottom_right.x), max(top_left.x, bottom_right.x) + 1):
			if draw_area.has_point(Vector2(x, y)) and x >= 0 and y >= 0 and x < img_width and y < img_height:
				var p = Vector2(x, y)
				var local_pos = p - draw_area_position
				Globals.DRAWING[local_pos.y][local_pos.x] = Globals.CURRENT_COLOR
				if Globals.CURRENT_COLOR < 0:
					image.set_pixelv(p, Color(1, 1, 1, 0))  # Transparent color
				else:
					image.set_pixelv(p, Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR])

func save_texture():	
	var pass1 = mix_layers(base_image, pattern_image)
	var pass2 = mix_layers(pass1, face_image)
	var error = pass2.save_png(Globals.FILE_PATH)
	if error == OK:
		print("Image saved successfully!")
	else:
		print("Error saving image!")
		
func mix_layers(base_image: Image, mix_image: Image) -> Image:
	var output_image = base_image.duplicate()
	for x in range(base_image.get_width()):
		for y in range(base_image.get_height()):
			# Get pixels from both images
			var base_pixel = base_image.get_pixel(x, y)
			var mix_pixel = mix_image.get_pixel(x, y)
			
			if mix_pixel.a > .5:
				output_image.set_pixel(x, y, mix_pixel)
			else:
				output_image.set_pixel(x, y, base_pixel)
	return output_image

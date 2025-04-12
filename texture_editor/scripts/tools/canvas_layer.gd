extends Control

var face_image
var face_texture
var base_image 
var base_texture
var pattern_image 
var pattern_texture

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

@onready var texture_rect : TextureRect = %TextureRect
@onready var full_rect: TextureRect = $display

func _ready():
	face_image = Image.create(1500, 1500, false, Image.FORMAT_RGBA8)
	face_image.fill(Color(1, 1, 1, 0)) 
	
	texture_rect.set_position(-Globals.DRAW_AREA_OFFSET)
	face_texture = ImageTexture.create_from_image(face_image)
	texture_rect.texture = face_texture
		
	var at = AtlasTexture.new()
	at.atlas = face_texture
	at.region = Rect2(Globals.DRAW_AREA_OFFSET, Globals.DRAW_AREA_SIZE)
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
	submit.connect("pressed", _on_save)
	
	save_state()

func _on_undo():
	%Undo.undo(face_image, face_texture)
	
func _on_redo():
	%Redo.redo(face_image, face_texture)
	
func _on_save():
	%Submit.save_texture(base_image, face_image, pattern_image)

func _on_background_change():
	%BackgroundColors.change_background(base_image, base_texture)

func _on_stamp_2(i: int):
	Globals.STAMP_2_ENABLED = true
	stamp2_index = i
	stamp2_image = load("res://themes/stamps/stamp2_"+str(stamp2_index)+".svg").get_image()

func _on_palette_selected(id: int): 
	%PaletteSwitcher.update_palette(face_image, face_texture, base_image, base_texture, id)
	if !Globals.SUPPRESS_SAVE: 
		save_state()
	Globals.SUPPRESS_SAVE = false 
	
func _on_clear():
	%Clear.clear(face_image, face_texture)
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

	var shader_material = load("res://assets/PlayerLayers.tres") as ShaderMaterial
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
			if Globals.DRAW_AREA.has_point(local_pos):
				if Globals.BUCKET_ENABLED:
					%Bucket.bucket_fill(face_image, face_texture, local_pos)
					save_state()
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
					%Stamp1.draw_stamp_on_canvas(face_image, Globals.STAMP1_IMAGE, local_pos)
					Globals.STAMP_1_ENABLED = false
					%Stamp1.button_pressed = false
					save_state()
				elif Globals.STAMP_2_ENABLED: 
					%Stamp1.draw_stamp_on_canvas(face_image, stamp2_image, local_pos)
					Globals.STAMP_2_ENABLED = false
					%Stamp2.button_pressed = false
					save_state()
				else:
					is_drawing = true
					previous_pos = local_pos 
					%Pen.draw_at(face_image, face_texture, local_pos)
		else:
			if is_line_drawing:
				is_line_drawing = false
				%Line.draw_line_on_canvas(face_image, face_texture, line_start_pos, line_end_pos)
				save_state()
			elif is_circle_drawing:
				is_circle_drawing = false
				%"Circle Tool".draw_circle_on_canvas(face_image, circle_start_pos, circle_radius)
				face_texture.update(face_image)
				save_state()
			elif is_rectangle_drawing:
				is_rectangle_drawing = false
				%"Rectangle Tool".draw_rectangle_on_canvas(face_image, rectangle_start_pos, rectangle_width, rectangle_height)  # Finalize the rectangle drawing
				face_texture.update(face_image)
				save_state()
			elif is_drawing:
				is_drawing = false
				save_state()
	var local_pos = texture_rect.get_local_mouse_position()
	if event is InputEventMouseMotion and Globals.DRAW_AREA.has_point(local_pos):
		if Globals.STAMP_1_ENABLED:
			var preview_image = Globals.UNDO_STACK[-1][0].duplicate()
			%Stamp1.draw_stamp_on_canvas(preview_image, Globals.STAMP1_IMAGE, local_pos, true)
			face_texture.update(preview_image)
		if Globals.STAMP_2_ENABLED:
			var preview_image = Globals.UNDO_STACK[-1][0].duplicate()
			%Stamp1.draw_stamp_on_canvas(preview_image, stamp2_image, local_pos, true)
			face_texture.update(preview_image)
		elif is_circle_drawing:
			circle_radius = int(circle_start_pos.distance_to(local_pos)) 
			var preview_image = Globals.UNDO_STACK[-1][0].duplicate()
			%"Circle Tool".draw_circle_on_canvas(preview_image, circle_start_pos, circle_radius)
			face_texture.update(preview_image)
		elif is_rectangle_drawing:
			rectangle_width = int(local_pos.x - rectangle_start_pos.x) 
			rectangle_height = int(local_pos.y - rectangle_start_pos.y)
			var preview_image = Globals.UNDO_STACK[-1][0].duplicate()
			%"Rectangle Tool".draw_rectangle_on_canvas(preview_image, rectangle_start_pos, rectangle_width, rectangle_height)
			face_texture.update(preview_image)
		elif is_line_drawing: 
			var preview_image = Globals.UNDO_STACK[-1][0].duplicate()
			%Line.draw_line_on_canvas(preview_image, face_texture, line_start_pos, line_end_pos)
			face_texture.update(preview_image)
			line_end_pos = local_pos
		elif is_drawing and Globals.DRAW_AREA.has_point(local_pos):
			%Pen.draw_between(face_image, face_texture, previous_pos, local_pos)
			previous_pos = local_pos

func save_state():
	Globals.UNDO_STACK.append([face_image.duplicate(), Globals.DRAWING.duplicate(true), Globals.CURRENT_PALETTE])
	if Globals.UNDO_STACK.size() > 10:
		Globals.UNDO_STACK.pop_front() 
	Globals.REDO_STACK.clear()

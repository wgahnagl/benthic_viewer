extends Control

var image
var texture
var base_image 
var base_texture

var pattern_image 
var pattern_texture
var mirror_enabled := true 
var mirror_pos = 100

var draw_area
var is_drawing = false
var previous_pos = Vector2()

@export var draw_area_position : Vector2 = Vector2(250, 120)  
@export var draw_area_size : Vector2 = Vector2(200, 200)

@onready var texture_rect : TextureRect = %TextureRect
@onready var full_rect: TextureRect = $display

var grid = []

func _ready():
	image = Image.create(1500, 1500, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 0)) 
	
	texture_rect.set_position(-draw_area_position)
	texture = ImageTexture.create_from_image(image)
	texture_rect.texture = texture
	
	draw_area = Rect2(draw_area_position, draw_area_size)
	
	var at = AtlasTexture.new()
	at.atlas = texture
	at.region = Rect2(draw_area_position, draw_area_size)
	full_rect.texture = at 
	
	full_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	set_player_texture(texture)
	
	var palette_selector = %PaletteSwitcher
	palette_selector.connect("palette_selected", _on_palette_selected)
	
	var background_color = %BackgroundColors
	background_color.connect("pressed", _on_background_change)

func _on_palette_selected(id):
	for y in range(Globals.DRAWING.size()):
		var row = Globals.DRAWING[y]
		for x in range(row.size()):
			var color_id = row[x]
			var p = Vector2(x + draw_area_position.x, y + draw_area_position.y)
			if color_id < 0: 
				image.set_pixelv(p, Color(1,1,1,0))
			else: 
				image.set_pixelv(p, Globals.PALETTES[id][color_id])
	base_image.fill(Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_BACKGROUND_COLOR])
	base_texture.update(base_image)
	texture.update(image)

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
	if event is InputEventMouseButton:
		if event.pressed:
			var local_pos = texture_rect.get_local_mouse_position()
			if draw_area.has_point(local_pos):
				is_drawing = true
				previous_pos = local_pos 
				draw_at(local_pos)
		else:
			is_drawing = false
	
	if event is InputEventMouseMotion and is_drawing:
		var local_pos = texture_rect.get_local_mouse_position()
		if draw_area.has_point(local_pos):
			draw_between(previous_pos, local_pos)
			previous_pos = local_pos

func draw_at(pos: Vector2):	
	var width = image.get_width()
	var height = image.get_height()
	for y in range(-Globals.CURRENT_BRUSH_SIZE, Globals.CURRENT_BRUSH_SIZE):
		for x in range(-Globals.CURRENT_BRUSH_SIZE, Globals.CURRENT_BRUSH_SIZE):
			var p = pos + Vector2(x, y)
			if draw_area.has_point(p) and p.x >= 0 and p.y >= 0 and p.x < width and p.y < height:
				var local_pos = p - draw_area_position
				Globals.DRAWING[local_pos.y][local_pos.x] = Globals.CURRENT_COLOR  # Note the flip (y, x)
				image.set_pixelv(p, Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR])
				
				if Globals.MIRROR_ENABLED:
					var mirror_x = draw_area_position.x * 2 + draw_area_size.x - p.x - 1
					var mirror_pos = Vector2(mirror_x, p.y)
					if mirror_pos.x >= 0 and mirror_pos.x < width:
						var mirror_local_pos = mirror_pos - draw_area_position
						Globals.DRAWING[mirror_local_pos.y][mirror_local_pos.x] = Globals.CURRENT_COLOR
						image.set_pixelv(mirror_pos, Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR])
	texture.update(image)
	queue_redraw()

func draw_between(start_pos: Vector2, end_pos: Vector2):
	var num_steps = int(start_pos.distance_to(end_pos))
	for step in range(num_steps):
		var lerp_pos = start_pos.lerp(end_pos, step / float(num_steps))
		draw_at(lerp_pos) 

func _on_background_change():
	base_image.fill(Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR])
	base_texture.update(base_image)

extends Control

var image
var texture
var draw_area
var is_drawing = false
var previous_pos = Vector2()


@export var draw_area_position : Vector2 = Vector2(250, 120)  # Exported position of the draw area
@export var draw_area_size : Vector2 = Vector2(200, 200)  # Exported size of the draw area

@onready var texture_rect : TextureRect = %TextureRect
@onready var full_rect: TextureRect = $display
@onready var camera : Camera2D = $SubViewport/Camera2D  # Assuming you have a Camera2D node in the SubViewport

func _ready():
	
	# Create the image (1500x1500 texture)
	image = Image.create(1500, 1500, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))  # Fill the image with transparency
	texture_rect.set_position(-draw_area_position)
	# Create the ImageTexture
	texture = ImageTexture.create_from_image(image)
	# Set the TextureRect to display the 200x200 section
	texture_rect.texture = texture
		
	# Define the portion of the image to show in the TextureRect (200x200 region)
	draw_area = Rect2(draw_area_position, draw_area_size)

	var at = AtlasTexture.new()
	at.atlas = texture
	at.region = Rect2(draw_area_position, draw_area_size)

	full_rect.texture = at  # Assign the full texture to the new TextureRect
		# Set the stretch mode to scale the texture
	full_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	set_player_texture(texture)

func set_player_texture(new_texture: ImageTexture):
	# Assuming your player has a MeshInstance3D with a material
	var mesh_instance = %Player/CustomArmature/Skeleton3D/player  # Find the mesh instance inside the player
	if mesh_instance:
		var material = mesh_instance.get_active_material(0)
		print(material)
		if material:
			if material is StandardMaterial3D:
				# If you're using a custom shader, you can set it like this:
				material.set_texture(0, new_texture)
			else:
				print("Material type not supported!")
		else:
			print("MeshInstance3D has no material!")
	else:
		print("MeshInstance3D not found in player!")
		
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			# Start drawing when the mouse button is pressed
			var local_pos = texture_rect.get_local_mouse_position()
			if draw_area.has_point(local_pos):
				is_drawing = true
				previous_pos = local_pos  # Set the previous position to the current mouse position
				draw_at(local_pos)  # Draw at the starting point
		else:
			# Stop drawing when the mouse button is released
			is_drawing = false
	
	if event is InputEventMouseMotion and is_drawing:
		# Only draw if we're in drawing mode
		var local_pos = texture_rect.get_local_mouse_position()
		if draw_area.has_point(local_pos):
			# Interpolate between the previous position and the current position
			draw_between(previous_pos, local_pos)
			previous_pos = local_pos  # Update the previous position for the next frame

func draw_at(pos: Vector2):
	# Draw a simple point or small shape
	var width = image.get_width()
	var height = image.get_height()
	
	# Iterate over a 9x9 grid (from -4 to 4 in both directions) to draw at the position
	for y in range(-4, 5):
		for x in range(-4, 5):
			var p = pos + Vector2(x, y)  # Calculate the pixel position to draw on
			# Check if the pixel position is within the bounds of the image and the drawing area
			if draw_area.has_point(p) and p.x >= 0 and p.y >= 0 and p.x < width and p.y < height:
				# Set the pixel to red
				image.set_pixelv(p, Color.RED)
	
	# Update the texture with the modified image
	texture.update(image)
	queue_redraw()  # Request to redraw the canvas

func draw_between(start_pos: Vector2, end_pos: Vector2):
	# Use line interpolation to draw a smooth line between two points
	var num_steps = int(start_pos.distance_to(end_pos))  # Number of steps for interpolation
	for step in range(num_steps):
		var lerp_pos = start_pos.lerp(end_pos, step / float(num_steps))
		draw_at(lerp_pos)  # Draw at the interpolated position

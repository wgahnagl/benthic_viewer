extends Node2D

class_name PixelEditor

@export var canvas_size: Vector2 = Vector2(32, 32)
@export var pixel_size: int = 5;

var pixel_grid = {}
var selected_color = Color(1, 1, 1, 1)
var is_drawing = false
var last_draw_pos = null

func _ready():
	canvas_size.x = canvas_size.x/pixel_size
	canvas_size.y = canvas_size.y/pixel_size
	initialize_canvas()
	set_process_input(true)

func initialize_canvas():
	pixel_grid.clear()
	for x in range(canvas_size.x):
		for y in range(canvas_size.y):
			pixel_grid[Vector2(x, y)] = Color(0, 0, 0, 0)
	queue_redraw()

func _input(event):
	if not is_visible_in_tree():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_drawing = true
			last_draw_pos = null
			_draw_at(event.position)
		else:
			is_drawing = false
			last_draw_pos = null

	elif event is InputEventMouseMotion and is_drawing:
		_draw_at(event.position)

func _draw_at(position: Vector2):
	var grid_pos = (to_local(position) / pixel_size).floor()

	if pixel_grid.has(grid_pos):
		if last_draw_pos == null:
			pixel_grid[grid_pos] = selected_color
		else:
			# Interpolate between last and current
			var delta = grid_pos - last_draw_pos
			var steps = max(abs(delta.x), abs(delta.y))
			for i in range(steps + 1):
				var interp_pos = last_draw_pos.lerp(grid_pos, i / float(steps)).floor()
				if pixel_grid.has(interp_pos):
					pixel_grid[interp_pos] = selected_color
		last_draw_pos = grid_pos
		queue_redraw()

func _is_within_bounds(position: Vector2) -> bool:
	var local_pos = to_local(position)
	return local_pos.x >= 0 and local_pos.y >= 0 and local_pos.x < canvas_size.x * pixel_size and local_pos.y < canvas_size.y * pixel_size

func _draw():
	for pos in pixel_grid.keys():
		draw_rect(Rect2(pos * pixel_size, Vector2(pixel_size, pixel_size)), pixel_grid[pos])

func set_color(new_color: Color):
	selected_color = new_color

func set_canvas_size(new_size: Vector2):
	canvas_size = new_size
	initialize_canvas()
	queue_redraw()

func _process(_delta):
	if get_parent():
		scale = get_parent().scale

func save_image(path: String):
	var image = Image.create(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	
	# Fill the image with pixel data
	for pos in pixel_grid.keys():
		var color = pixel_grid[pos]
		image.set_pixelv(pos, color)
		
	var raw_data: PackedByteArray = image.get_data()
	var width = image.get_width()
	var height = image.get_height()
	
	get_tree().root.get_child(0).process_image(width, height, raw_data, "player_models/muffing_skin.png")
	image.save_png(path)

func load_image(path: String):
	var image = Image.new()
	var err = image.load(path)
	if err != OK:
		print("Failed to load image: ", path)
		return
	
	image.resize(canvas_size.x, canvas_size.y)  # Resize to match canvas size

	# Populate pixel_grid with image data
	for x in range(canvas_size.x):
		for y in range(canvas_size.y):
			var color = image.get_pixel(x, y)
			pixel_grid[Vector2(x, y)] = color
	
	queue_redraw()

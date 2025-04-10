@tool
extends Node

var PRIMARY = Color("#3498db")
var SECONDARY = Color("#00c0d1")
var TERTIARY = Color("#8ae7d4")
var COLOR4 = Color("#86ea1f")
var TEXT = Color("#ffffff")
var BACKGROUND = Color("#1e1e1e")

# For button presses, to unify how dark they become on hover and press
var DARK_FACTOR1 = 0.9
var DARK_FACTOR2 = 0.7

var PRIMARY_FONT = "MochiyPopOne-Regular"
var theme_name = "benthic_theme"

func _ready():
	var theme = Theme.new()
	setFont(theme)
	setPopup(theme, 5, 5)

	setToolPanel(theme, 30, 20)
	setBasePanel(theme, 10)
	
	generate_circle_buttons(theme, 20)
	generate_circle_2(theme, 20)
	setSubmitButton(theme, 20, 12)
	# Generate buttons and theme variants for simple images 
	generateImageButton(theme, "PaintDrop")
	generateImageButton(theme, "PaintPalette", "White", "MenuButton")
	generate_circle_buttons(theme, 20, "MenuButton")
	generateImageButton(theme, "Arrow")
	
	var path = "res://themes/" + theme_name + ".tres"
	var error = ResourceSaver.save(theme, path)
	if error == OK:
		print("Theme saved to:", path)
	else:
		print("Failed to save theme:", error)

func setSubmitButton(theme: Theme, corner_radius: int, margin_size: int): 
	theme.set_type_variation("SubmitButton", "Button")	
	var stylebox = StyleBoxFlat.new()
	var focus_stylebox = StyleBoxEmpty.new()
	
	stylebox.corner_radius_top_left = corner_radius
	stylebox.corner_radius_top_right = corner_radius
	stylebox.corner_radius_bottom_left = corner_radius
	stylebox.corner_radius_bottom_right = corner_radius
	
	stylebox.content_margin_left = margin_size
	stylebox.content_margin_top = margin_size
	stylebox.content_margin_right = margin_size
	stylebox.content_margin_bottom = margin_size
	
	var hover_stylebox = stylebox.duplicate() 
	var click_stylebox = stylebox.duplicate()
	
	theme.set_stylebox("focus", "SubmitButton", focus_stylebox)
	
	stylebox.bg_color = COLOR4
	theme.set_color("font_color", "SubmitButton", PRIMARY)
	theme.set_stylebox("normal", "SubmitButton", stylebox)

	
	hover_stylebox.bg_color = set_hover_color(COLOR4)
	theme.set_color("font_hover_color", "SubmitButton", set_hover_color(PRIMARY)) 
	theme.set_stylebox("hover", "SubmitButton", hover_stylebox)
	
	click_stylebox.bg_color = set_click_color(COLOR4)
	theme.set_color("font_focus_color", "SubmitButton", set_click_color(SECONDARY)) 
	theme.set_stylebox("pressed", "SubmitButton", click_stylebox)

func generateImageButton(theme: Theme, typeName: String, color = TERTIARY, baseType = "Button"): 
	theme.set_type_variation(typeName, baseType)	
	var stylebox = load("res://themes/"+typeName+".tres")
	var focus_stylebox = StyleBoxEmpty.new()
	
	stylebox.modulate_color = color
	var hover_stylebox = stylebox.duplicate() 
	var click_stylebox = stylebox.duplicate()

	theme.set_stylebox("focus", typeName, focus_stylebox)
	
	theme.set_stylebox("normal", typeName, stylebox)
	
	hover_stylebox.modulate_color = set_hover_color(Color(color))
	theme.set_stylebox("hover", typeName, hover_stylebox)
	
	click_stylebox.modulate_color = set_click_color(Color(color))
	theme.set_stylebox("pressed", typeName, click_stylebox)

func setToolPanel(theme: Theme, corner_radius: int, margin_size: int): 
	theme.set_type_variation("ToolPanel", "PanelContainer")
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = TERTIARY
	
	stylebox.corner_radius_top_left = corner_radius
	stylebox.corner_radius_top_right = corner_radius
	stylebox.corner_radius_bottom_left = corner_radius
	stylebox.corner_radius_bottom_right = corner_radius
	
	stylebox.content_margin_left = margin_size
	stylebox.content_margin_top = margin_size
	stylebox.content_margin_right = margin_size
	stylebox.content_margin_bottom = margin_size
	
	theme.set_stylebox("panel", "ToolPanel", stylebox)
	
func setPopup(theme: Theme, corner_radius: int, margin_size: int): 
	theme.set_type_variation("PalettePanel", "PopupPanel")
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = SECONDARY
	var hover_stylebox = stylebox.duplicate() 
	
	stylebox.corner_radius_top_left = corner_radius
	stylebox.corner_radius_top_right = corner_radius
	stylebox.corner_radius_bottom_left = corner_radius
	stylebox.corner_radius_bottom_right = corner_radius
	
	stylebox.content_margin_left = margin_size
	stylebox.content_margin_top = margin_size
	stylebox.content_margin_right = margin_size
	stylebox.content_margin_bottom = margin_size
	
	theme.set_stylebox("normal", "PopupPanel", stylebox)
	theme.set_stylebox("normal", "PopupMenu", stylebox)
	theme.set_stylebox("panel", "PopupMenu", stylebox)
	
	hover_stylebox.bg_color = set_hover_color(SECONDARY)
	theme.set_stylebox("item_hover", "PopupMenu", hover_stylebox)
	theme.set_stylebox("hover", "PopupMenu", hover_stylebox)  
	
	theme.set_stylebox("item_selected", "PopupMenu", stylebox)  # Selected effect, if needed
	
func setBasePanel(theme: Theme, margin_size: int): 
	theme.set_type_variation("BasePanel", "PanelContainer")
	var stylebox = load("res://themes/blob.tres")
	stylebox.modulate_color = PRIMARY
	
	stylebox.content_margin_left = margin_size
	stylebox.content_margin_top = margin_size
	stylebox.content_margin_right = margin_size
	stylebox.content_margin_bottom = margin_size
	
	theme.set_stylebox("panel", "BasePanel", stylebox)

func setFont(theme: Theme):
	var font = FontFile.new()
	font.font_data = load("res://fonts/"+PRIMARY_FONT+".ttf") 
	
	theme.set_font("font", "Label", font) 
	theme.set_font("font", "Button", font)
	theme.set_font("font", "LineEdit", font)
	theme.set_font("font", "TextEdit", font)
	
func generate_circle_buttons(theme: Theme, button_size: int, type = "Button"):
	var stylebox = load("res://themes/CircleBase.tres")
	var base_style = stylebox.duplicate() 
	var focus_stylebox = StyleBoxEmpty.new()
	theme.set_type_variation("CircleButton", type)
	base_style.modulate_color = SECONDARY
	
	theme.set_stylebox("normal", "CircleButton", base_style)

	base_style.content_margin_left = button_size
	base_style.content_margin_top = button_size
	base_style.content_margin_right = button_size
	base_style.content_margin_bottom = button_size 
	var hover_stylebox = base_style.duplicate() 
	var click_stylebox = base_style.duplicate()
	
	theme.set_stylebox("focus", "CircleButton", focus_stylebox)
	
	theme.set_stylebox("normal", "CircleButton", base_style)
	
	hover_stylebox.modulate_color = set_hover_color(SECONDARY)
	theme.set_stylebox("hover", "CircleButton", hover_stylebox)
	
	click_stylebox.modulate_color = set_click_color(SECONDARY)
	theme.set_stylebox("pressed", "CircleButton", click_stylebox)

func generate_circle_2(theme: Theme, button_size: int):	
	var stylebox = load("res://themes/CircleBase.tres")
	var style_border = load("res://themes/CircleBorder.tres")
	var base_style = stylebox.duplicate() 
	var border_style = style_border.duplicate()
	var focus_stylebox = StyleBoxFlat.new()
	theme.set_type_variation("CircleButton2", "Button")
	var base_image = base_style.texture.get_image()
	var border_image = border_style.texture.get_image()
	
	var final_image = generate_border(base_image, border_image, SECONDARY, TERTIARY)
	var final_texture = ImageTexture.create_from_image(final_image)
	base_style.texture = final_texture
	theme.set_stylebox("normal", "CircleButton2", base_style)

	base_style.content_margin_left = button_size
	base_style.content_margin_top = button_size
	base_style.content_margin_right = button_size
	base_style.content_margin_bottom = button_size 
	
	var hover_stylebox = base_style.duplicate() 
	var click_stylebox = base_style.duplicate()
	
	focus_stylebox.bg_color = Color(0, 0, 0, 0) # hide the focus 
	theme.set_stylebox("focus", "CircleButton2", focus_stylebox)
	
	theme.set_stylebox("normal", "CircleButton2", base_style)
	
	hover_stylebox.modulate_color = set_hover_color(SECONDARY)
	theme.set_stylebox("hover", "CircleButton2", hover_stylebox)
	
	click_stylebox.modulate_color = set_click_color(SECONDARY)
	theme.set_stylebox("pressed", "CircleButton2", click_stylebox)

func generate_border(base_image: Image, border_image: Image, base_color: Color, border_color: Color) -> Image:
	var output_image = base_image.duplicate()
	for x in range(base_image.get_width()):
		for y in range(base_image.get_height()):
			# Get pixels from both images
			var base_pixel = base_image.get_pixel(x, y)
			var border_pixel = border_image.get_pixel(x, y)
			
			if base_pixel.a > 0:
				base_pixel = base_pixel * base_color
			if border_pixel.a > 0: 
				border_pixel = border_pixel * border_color

			if border_pixel.a > .5:
				output_image.set_pixel(x, y, border_pixel)
			else:
				output_image.set_pixel(x, y, base_pixel)
	return output_image
	
func set_hover_color(color: Color) -> Color:
	var hover_color = Color(color) * DARK_FACTOR1
	hover_color.a = 1.0
	return hover_color

func set_click_color(color: Color) -> Color:
	var click_color = Color(color) * DARK_FACTOR2
	click_color.a = 1.0 
	return click_color

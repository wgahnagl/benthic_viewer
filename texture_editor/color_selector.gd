extends GridContainer

func _ready():
	var color_selector = %"Color Selector"
	color_selector.set_button_color(Globals.PALETTES[0])
	
	var palette_selector = %PaletteSwitcher
	palette_selector.connect("palette_selected", _on_palette_selected)

func _on_palette_selected(id):
	set_button_color(Globals.PALETTES[id])
	Globals.CURRENT_PALETTE = Globals.PALETTES[id]
			
func set_button_color(palette: Array):
	var buttons = $".".get_children()
	for i in range(buttons.size()):
		var button = buttons[i]
		var stylebox = button.get_theme_stylebox("normal")
		var new_stylebox = stylebox.duplicate()
		new_stylebox.modulate_color = palette[i]
		
		var hover_stylebox = new_stylebox.duplicate()
		hover_stylebox.modulate_color  = set_hover_color(palette[i])
		var click_stylebox = new_stylebox.duplicate()
		click_stylebox.modulate_color = set_click_color(palette[i])
		button.add_theme_stylebox_override("normal", new_stylebox)
		button.add_theme_stylebox_override("hover", hover_stylebox)
		button.add_theme_stylebox_override("pressed", click_stylebox)
		button.pressed.connect(_on_color_change.bind(i))

func _on_color_change(i: int):
	Globals.CURRENT_COLOR = i

func set_hover_color(color: Color) -> Color:
	var hover_color = Color(color) * 0.9
	hover_color.a = 1.0
	return hover_color

func set_click_color(color: Color) -> Color:
	var click_color = Color(color) * 0.7
	click_color.a = 1.0 
	return click_color

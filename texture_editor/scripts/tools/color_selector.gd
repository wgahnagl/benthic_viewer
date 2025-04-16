extends GridContainer


func _ready():
	var color_selector = %"Color Selector"
	color_selector.update_button_colors(0)

	var palette_selector = %PaletteSwitcher
	palette_selector.connect("palette_selected", _on_palette_selected)
	var buttons = $".".get_children()
	for i in range(buttons.size()):
		var button = buttons[i]
		button.pressed.connect(_on_color_change.bind(i))
	Globals.set_button_color(%CurrentColor, Globals.CURRENT_PALETTE, Globals.CURRENT_COLOR)


func _on_palette_selected(id):
	update_button_colors(id)
	Globals.CURRENT_PALETTE = id


func update_button_colors(palette: int):
	var buttons = $".".get_children()
	for i in range(buttons.size()):
		Globals.set_button_color(buttons[i], palette, i)


func _on_color_change(i: int):
	Globals.CURRENT_COLOR = i
	%Eraser.button_pressed = false
	Globals.set_button_color(%CurrentColor, Globals.CURRENT_PALETTE, i)

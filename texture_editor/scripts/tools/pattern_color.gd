extends Button


func _ready() -> void:
	$".".connect("pressed", _on_button_press)
	Globals.set_button_color($".", Globals.CURRENT_PALETTE, Globals.CURRENT_PATTERN_COLOR)
	var palette_selector = %PaletteSwitcher
	palette_selector.connect("palette_selected", _on_palette_selected)

func _on_button_press():
	if Globals.CURRENT_COLOR >= 0:
		Globals.set_button_color($".", Globals.CURRENT_PALETTE, Globals.CURRENT_COLOR)
		Globals.CURRENT_PATTERN_COLOR = Globals.CURRENT_COLOR
		%CanvasBackground.get_theme_stylebox("panel").bg_color = (
			Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR]
		)

func _on_palette_selected(i: int):
	Globals.set_button_color($".", i, Globals.CURRENT_PATTERN_COLOR)
	%CanvasBackground.get_theme_stylebox("panel").bg_color = Globals.PALETTES[i][
		Globals.CURRENT_PATTERN_COLOR
	]

func change_pattern_color(image: Image, texture: Texture):
	if Globals.CURRENT_COLOR >= 0:
		image.fill(Globals.PALETTES[Globals.CURRENT_PALETTE][Globals.CURRENT_COLOR])
		texture.update(image)

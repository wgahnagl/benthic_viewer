extends GridContainer

var PALETTE1 = [
	Color("ff595eff"),
	Color("ff924cff"),
	Color("ffca3aff"),
	Color("8ac926ff"),
	Color("36949dff"),
	Color("1982c4ff"),
	Color("565aa0ff"),
	Color("ffffffff"),
	Color("000000ff"),
	Color("a56c32ff"),
	Color("80807fff")
]
var PALETTE2 = []
var PALETTE3 = []
var PALETTE4 = []
var PALETTE5 = []

func _ready():
	var palette_selector = %PaletteSwitcher
	palette_selector.connect("palette_selected", _on_palette_selected)

func _on_palette_selected(id):
	match id: 
		0:
			set_button_color(PALETTE1)
			
func set_button_color(palette: Array):
	var buttons = $".".get_children()
	for i in range(buttons.size()):
		var button = buttons[i]
		var normal_color = palette[i]
		var theme = button.get_theme()
		print(theme)

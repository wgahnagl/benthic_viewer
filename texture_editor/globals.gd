extends Node

var COLOR1 = Color("#3498db")
var COLOR2 = Color("#00c0d1")
var COLOR3 = Color("#8ae7d4")
var COLOR4 = Color("#86ea1f")
var TEXT = Color("#ffffff")
var BACKGROUND = Color("#1e1e1e")

const PALETTES = [[
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
	], [
	Color("f9f9f9ff"),
	Color("f2f2f2ff"),
	Color("ecececff"),
	Color("e6e6e6ff"),
	Color("ccccccff"),
	Color("999999ff"),
	Color("666666ff"),
	Color("4d4d4dff"),
	Color("333333ff"),
	Color("1a1a1aff"),
	Color("000000ff")
	], [
	Color("20243bff"),
	Color("264653ff"),
	Color("287271ff"),
	Color("2a9d8fff"),
	Color("8ab17dff"),
	Color("e9c46aff"),
	Color("efb366ff"),
	Color("f4a261ff"),
	Color("ee8959ff"),
	Color("e76f51ff"),
	Color("e97c61ff")
	], [
	Color("ede0d4ff"),
	Color("e6ccb2ff"),
	Color("ddb892ff"),
	Color("b89684ff"),
	Color("7f5539ff"),
	Color("56310dff"),
	Color("9c6644ff"),
	Color("a57455ff"),
	Color("ad8164ff"),
	Color("b48c72ff"),
	Color("bb967fff")
	], [
	Color("eae4e9ff"),
	Color("fff1e6ff"),
	Color("fde2e4ff"),
	Color("fad2e1ff"),
	Color("e2ece9ff"),
	Color("bee1e6ff"),
	Color("f0efebff"),
	Color("dfe7fdff"),
	Color("cddafdff"),
	Color("d7e1fdff"),
	Color("cbbde7ff")
]]

#this is the drawing encoded as numbers
var DRAWING = []

var CURRENT_PALETTE = 0
var CURRENT_COLOR = 0
var CURRENT_BRUSH_SIZE = 3
var CURRENT_BACKGROUND_COLOR = 7
var MIRROR_ENABLED = false
var BUCKET_ENABLED = false
var LINE_ENABLED = false
var CIRCLE_ENABLED = false
var RECTANGLE_ENABLED = false
var LAST_COLOR = 0

func _ready() :
	for _i in range(200):
		var row = []
		for _j in range(200):
			row.append(-1)
		DRAWING.append(row)


func set_button_color(button: Button, palette: int, color: int):
	var stylebox = button.get_theme_stylebox("normal")
	var new_stylebox = stylebox.duplicate()
	new_stylebox.modulate_color = Globals.PALETTES[palette][color]

	var hover_stylebox = new_stylebox.duplicate()
	hover_stylebox.modulate_color  = set_hover_color(Globals.PALETTES[palette][color])
	var click_stylebox = new_stylebox.duplicate()
	click_stylebox.modulate_color = set_click_color(Globals.PALETTES[palette][color])
	button.add_theme_stylebox_override("normal", new_stylebox)
	button.add_theme_stylebox_override("hover", hover_stylebox)
	button.add_theme_stylebox_override("pressed", click_stylebox)

func set_hover_color(color: Color) -> Color:
	var hover_color = Color(color) * 0.9
	hover_color.a = 1.0
	return hover_color

func set_click_color(color: Color) -> Color:
	var click_color = Color(color) * 0.7
	click_color.a = 1.0 
	return click_color
	

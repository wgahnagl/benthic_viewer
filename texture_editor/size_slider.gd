extends VSlider

func _ready():
	$".".connect("value_changed", _on_slider_value_changed)

func _on_slider_value_changed(value):
	Globals.CURRENT_BRUSH_SIZE = value

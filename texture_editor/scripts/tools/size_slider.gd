extends VSlider


func _ready():
	$".".connect("value_changed", _on_slider_value_changed)


func _on_slider_value_changed(val):
	Globals.CURRENT_BRUSH_SIZE = val

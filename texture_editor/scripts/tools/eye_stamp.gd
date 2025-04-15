extends Button
signal stamp_selected(index: int)

@onready var popup := $StampPopup
@onready var grid := $StampPopup/GridContainer


func _ready() -> void:
	for i in range(2):  # Add as many as you like
		var texture = load("res://themes/stamps/stamp2_%d.svg" % i)
		var icon_button = TextureButton.new()
		icon_button.texture_normal = texture
		icon_button.connect("pressed", _on_stamp_pressed.bind(i))
		grid.add_child(icon_button)


func _on_pressed() -> void:
	Globals.BUCKET_ENABLED = false
	Globals.LINE_ENABLED = false
	Globals.RECTANGLE_ENABLED = false
	Globals.CIRCLE_ENABLED = false
	Globals.STAMP_1_ENABLED = false
	Globals.STAMP_2_ENABLED = true
	$"../Bucket".button_pressed = false
	$"../Line".button_pressed = false
	$"../Circle Tool".button_pressed = false
	$"../Rectangle Tool".button_pressed = false
	%Stamp1.button_pressed = false
	$".".button_pressed = true

	var button_position = global_position
	var button_size = size
	popup.position = Vector2(button_position.x + button_size.x, button_position.y)
	popup.popup()
	popup.transparent_bg = true


func _on_stamp_pressed(index: int) -> void:
	emit_signal("stamp_selected", index)
	popup.hide()

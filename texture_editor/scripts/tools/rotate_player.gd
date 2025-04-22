extends SubViewportContainer

var dragging: bool = false
var last_mouse_pos: Vector2
@onready var player: Node3D = $SubViewport/Node3D/Player


func rotate_model(delta):
	%Node3D.rotate_y(deg_to_rad(-delta.x * 0.5))

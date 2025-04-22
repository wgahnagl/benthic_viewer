extends GridContainer

@export var min_size = 50


func _ready():
	# Ensure children are square by modifying their rect_min_size dynamically
	_adjust_child_sizes()


# This function will loop through the children of the GridContainer and adjust their size to be square
func _adjust_child_sizes():
	for child in get_children():
		if child is Control:
			child.custom_minimum_size = Vector2(min_size, min_size)

extends Button

func undo(image: Image, texture: Texture):
	if Globals.UNDO_STACK.size() > 1:
		var current_state = Globals.UNDO_STACK.pop_back()
		Globals.REDO_STACK.append(current_state)
		var previous_state = Globals.UNDO_STACK[-1]
		image = previous_state[0].duplicate()
		Globals.DRAWING = previous_state[1].duplicate(true)
		Globals.SUPPRESS_SAVE = true
		%PaletteSwitcher.set_palette(previous_state[2])
		texture.update(image)

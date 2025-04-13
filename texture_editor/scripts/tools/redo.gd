extends Button

func redo(image: Image, texture:Texture):
	if Globals.REDO_STACK.size() > 0:
		var state = Globals.REDO_STACK.pop_back()
		image = state[0]
		Globals.DRAWING = state[1]
		Globals.SUPPRESS_SAVE = true 
		%PaletteSwitcher.set_palette(state[2])
		texture.update(image)
		Globals.UNDO_STACK.append([image.duplicate(), Globals.DRAWING.duplicate()])  # Save to undo stack

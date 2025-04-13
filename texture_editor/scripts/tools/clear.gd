extends Button 

func clear(image: Image, texture: Texture):
	for y in range(Globals.DRAWING.size()):
		var row = Globals.DRAWING[y]
		for x in range(row.size()):
			var p = Vector2(x + Globals.DRAW_AREA_OFFSET.x, y + Globals.DRAW_AREA_OFFSET.y)
			Globals.DRAWING[x][y] = -1
			image.set_pixelv(p, Color(1,1,1,0))
	texture.update(image)

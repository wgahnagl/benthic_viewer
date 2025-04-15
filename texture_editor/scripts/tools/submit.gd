extends Button


func save_texture(base_image: Image, face_image: Image, pattern_image: Image):
	var pass1 = mix_layers(base_image, pattern_image)
	var pass2 = mix_layers(pass1, face_image)
	var error = pass2.save_png(Globals.FILE_PATH)
	if error == OK:
		print("Image saved successfully!")
	else:
		print("Error saving image!")


func mix_layers(base_image: Image, mix_image: Image) -> Image:
	var output_image = base_image.duplicate()
	for x in range(base_image.get_width()):
		for y in range(base_image.get_height()):
			var mix_pixel = mix_image.get_pixel(x, y)
			if mix_pixel.a > 0.5:
				output_image.set_pixel(x, y, mix_pixel)
			else: 
				output_image.set_pixel(x, y, base_image.get_pixel(x, y))
	return output_image

use godot::classes::Control;
use godot::classes::IControl;
use godot::prelude::*;
use image::{ImageBuffer, Rgba};

#[derive(GodotClass)]
#[class(base=Control)]
struct TextureEdit {
    base: Base<Control> 
}

#[godot_api]
impl IControl for TextureEdit{
    fn init(base: Base<Control>) -> Self {
        Self{
            base
        }
    }
}

#[godot_api]
impl TextureEdit {
    #[func]
    fn process_image(&self, width: i32, height: i32, bytes: PackedByteArray, base_path: String){
        if bytes.len() != (width * height * 4) as usize {
            godot_error!("RGBA data size does not match width * height * 4");
            return;
        }

        let (w, h) = (width as u32, height as u32);
        let rgba_vec = bytes.to_vec();

        let img = match ImageBuffer::<Rgba<u8>, _>::from_raw(w, h, rgba_vec) {
            Some(img) => img,
            None => {
                godot_error!("Failed to create image buffer from RGBA data");
                return;
            }
        };

        let mut base_image = match image::open(&base_path) {
            Ok(img) => img.to_rgba8(),
            Err(_) => {
                godot_error!("Failed to open base PNG file");
                return;
            }
        };

        let (base_width, base_height) = base_image.dimensions();
        
        let base_pixels = base_image.as_mut();
        
        let overlay_pixels = img;

        for y in 0..overlay_pixels.height() {
            for x in 0..overlay_pixels.width() {
                let base_index = (y * base_width + x) as usize * 4; 
                
                if x < base_width && y < base_height {
                    let overlay_pixel = overlay_pixels.get_pixel(x, y);
                    let base_pixel = &mut base_pixels[base_index..base_index + 4];
                    
                    base_pixel[0] = overlay_pixel[0]; // R
                    base_pixel[1] = overlay_pixel[1]; // G
                    base_pixel[2] = overlay_pixel[2]; // B
                    base_pixel[3] = overlay_pixel[3]; // A
                }
            }
        }

        if let Err(_) = base_image.save("output.png") {
            godot_error!("Failed to save modified image");
            return;
        }

        godot_print!("SAVED TO OUTPUT.PNG");
    }
}

use godot::classes::Control;
use godot::classes::IControl;
use godot::prelude::*;

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
    fn process_image(&self, width: i32, height: i32, bytes: PackedByteArray){
        godot_print!("{:?}, {:?}, bytes: {:?}", height, width, bytes)
    }
}

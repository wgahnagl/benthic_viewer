use godot::classes::Button;
use godot::classes::IButton;
use godot::prelude::*;
use metaverse_session::session::new_session;
use metaverse_login::models::simulator_login_protocol::Login;
use tokio::runtime::Runtime;

#[derive(GodotClass)]
#[class(base=Button)]
struct LoginButton{
    base: Base<Button>
}

#[godot_api]
impl IButton for LoginButton{
    fn init(base: Base<Button>) -> Self {
        Self {
            base
        }
    }
}

#[godot_api]
impl LoginButton{
    #[func]
    fn send_login(&mut self, firstname: String, lastname: String, grid: String, password: String,){
        let firstname_clone = firstname.clone();
        let lastname_clone = lastname.clone();
        let grid_clone = grid.clone();
        let password_clone = password.clone();
        let rt = Runtime::new().expect("Failed to create Tokio runtime");
        
        let grid_clone = if grid_clone == "localhost" {
            "http://127.0.0.1".to_string()
        } else {
                grid_clone
            };

        // Spawn the async task within the runtime
        rt.spawn(async move {
            let session = new_session(Login {
                first: firstname_clone,
                last: lastname_clone,
                passwd: password_clone,
                channel: "benthic".to_string(),
                start: "home".to_string(),
                agree_to_tos: true,
                read_critical: true,
            }, build_url(&grid_clone, 9000)).await;

            // Optionally handle the result here if needed
            match session {
                Ok(_) => godot_print!("Login successful"),
                Err(e) => godot_print!("Login failed: {:?}", e),
            }
        });
        godot_print!("RECEIVED USERNAME {}", firstname);
        godot_print!("RECEIVED LASTNAME {}", lastname);
        godot_print!("RECEIVED GRID {}", grid);
        godot_print!("RECEIVED PASSWORD {}", password);
    }

    #[signal]
    fn send_login();
}

fn build_url(url: &str, port: u16) -> String {
    let mut url_string = "".to_owned();
    url_string.push_str(url);
    url_string.push(':');
    url_string.push_str(&port.to_string());
    println!("url string {}", url_string);
    url_string
}

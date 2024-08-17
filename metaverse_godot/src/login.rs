use actix::SystemRunner;
use godot::obj::WithBaseField;
use metaverse_login::models::simulator_login_protocol::Login;
use metaverse_messages::models::client_update_data::ClientUpdateData;
use std::sync::Arc;
use std::sync::Mutex;

use actix_rt::System;
use godot::classes::Control;
use godot::classes::IControl;
use godot::prelude::*;
use metaverse_session::session::Session;

#[derive(GodotClass)]
#[class(base=Control)]
struct MetaverseSession {
    base: Base<Control>,
    update_stream: Option<Arc<Mutex<Vec<ClientUpdateData>>>>,
    runtime: SystemRunner,
}

#[godot_api]
impl IControl for MetaverseSession {
    fn init(base: Base<Control>) -> Self {
        let rt = System::new();
        Self {
            base,
            update_stream: None,
            runtime: rt,
        }
    }
}

#[godot_api]
impl MetaverseSession {
    #[signal]
    fn check_stream();

    #[signal]
    fn init_session();

    #[signal]
    fn debug_message();

    #[func]
    fn init_session(
        &mut self,
        firstname: String,
        lastname: String,
        grid: String,
        password: String,
    ) {
        let firstname_clone = firstname.clone();
        let lastname_clone = lastname.clone();
        let grid_clone = grid.clone();
        let password_clone = password.clone();
        let grid_clone = if grid_clone == "localhost" {
            "http://127.0.0.1".to_string()
        } else {
            grid_clone
        };

        self.base_mut().emit_signal("debug_message".into(), &[]);

        let grid_clone = build_url(&grid_clone, 9000);

        let update_stream = Arc::new(Mutex::new(Vec::new()));
        let update_stream_clone = update_stream.clone();
        self.update_stream = Some(update_stream);

        let system = System::new();
        system.block_on(async {
            let result = Session::new(
                Login {
                    first: firstname_clone,
                    last: lastname_clone,
                    passwd: password_clone,
                    channel: "benthic".to_string(),
                    start: "home".to_string(),
                    agree_to_tos: true,
                    read_critical: true,
                },
                grid_clone,
                update_stream_clone.clone(),
            )
            .await;

            match result {
                Ok(_) => {
                    godot_print!("Login succeeded!");
                }
                Err(_) => {
                    godot_print!("Login failed");
                }
            }
        });
    }

    #[func]
    fn check_stream(&mut self) {
        if let Some(session) = self.update_stream.as_ref() {
            let stream = {
                let mut stream_lock = session.lock().unwrap();
                stream_lock.drain(..).collect::<Vec<_>>()
            };

            if !stream.is_empty() {
                for update in stream {
                    match update {
                        ClientUpdateData::String(data) => {
                            godot_print!("Data received: {}", data);
                            self.base_mut().emit_signal("debug_message".into(), &[]);
                        }
                        ClientUpdateData::Packet(packet) => {
                            godot_print!("Packet received: {:?}", packet);
                            self.base_mut().emit_signal("debug_message".into(), &[]);
                        }
                        ClientUpdateData::LoginProgress(login) => {
                            godot_print!(
                                "Login process at: {:?}, {:?}",
                                login.message,
                                login.percent
                            );
                            self.base_mut().emit_signal("debug_message".into(), &[]);
                        }
                        ClientUpdateData::Error(error) => {
                            godot_print!("Error received: {:?}", error);
                            self.base_mut().emit_signal("debug_message".into(), &[]);
                        }
                    }
                }
            }
        }
    }
}

fn build_url(url: &str, port: u16) -> String {
    let mut url_string = "".to_owned();
    url_string.push_str(url);
    url_string.push(':');
    url_string.push_str(&port.to_string());
    println!("url string {}", url_string);
    url_string
}

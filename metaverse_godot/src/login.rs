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

#[derive(GodotClass, Debug)]
#[class(base=Control)]
struct MetaverseSession {
    base: Base<Control>,
    update_stream: Arc<Mutex<Vec<ClientUpdateData>>>,
    runtime: SystemRunner,
}

#[godot_api]
impl IControl for MetaverseSession {
    fn init(base: Base<Control>) -> Self {
        let runtime = System::new();
        let update_stream = Arc::new(Mutex::new(Vec::new()));
        godot_print!("INITIALIZING METAVERSE SESSION");
        Self {
            base,
            update_stream,
            runtime,
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
    fn debug_message(&self, message_type: String, message: String);

    #[signal]
    fn client_update(&self, message_type: String, message: String);

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

        self.base_mut().emit_signal(
            "debug_message".into(),
            &["String".to_variant(), "string2".to_variant()],
        );

        let grid_clone = build_url(&grid_clone, 9000);

        self.base_mut().emit_signal(
            "client_update".into(),
            &["String".to_variant(), "string2".to_variant()],
        );
        let update_stream_clone = self.update_stream.clone();

        self.runtime.block_on(async {
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
        let stream = {
            let mut stream_lock = self.update_stream.lock().unwrap();
            stream_lock.drain(..).collect::<Vec<_>>()
        };

        if !stream.is_empty() {
            for update in stream {
                match update {
                    ClientUpdateData::String(data) => {
                        godot_print!("Data received: {}", data);
                        self.base_mut().emit_signal(
                            "client_update".into(),
                            &["String".to_variant(), data.to_variant()],
                        );
                    }
                    ClientUpdateData::Packet(packet) => {
                        godot_print!("Packet received: {:?}", packet);
                        self.base_mut().emit_signal(
                            "client_update".into(),
                            &["Packet".to_variant(), format!("{:?}", packet).to_variant()],
                        );
                    }
                    ClientUpdateData::LoginProgress(login) => {
                        godot_print!("Login process at: {:?}, {:?}", login.message, login.percent);
                        // since you can't use the login message, check the percent for 100 to
                        // verify login success
                        self.base_mut().emit_signal(
                            "client_update".into(),
                            &[
                                "LoginProgress".to_variant(),
                                format!("{:?}", login.percent).to_variant(),
                            ],
                        );
                    }
                    ClientUpdateData::Error(error) => {
                        godot_print!("Error received: {:?}", error);
                        self.base_mut().emit_signal(
                            "client_update".into(),
                            &["Error".to_variant(), format!("{:?}", error).to_variant()],
                        );
                    }
                    ClientUpdateData::ChatFromSimulator(chat) => {
                        godot_print!("Chat received: {:?}", chat);
                        self.base_mut().emit_signal(
                            "client_update".into(),
                            &["Chat".to_variant(), format!("{:?}", chat).to_variant()],
                        );
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

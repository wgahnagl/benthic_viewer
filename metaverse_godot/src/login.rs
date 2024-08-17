use actix::SystemRunner;
use metaverse_login::models::simulator_login_protocol::Login;
use metaverse_messages::models::client_update_data::ClientUpdateContent;
use metaverse_messages::models::client_update_data::ClientUpdateData;
use metaverse_messages::models::client_update_data::DataContent;
use std::sync::Arc;
use tokio::sync::Mutex;

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
                    let mut stream = update_stream_clone.lock().await;
                    stream.push(ClientUpdateData {
                        content: ClientUpdateContent::Data(DataContent {
                            content: format!("Login succeeded!"),
                        }),
                    });
                }
                Err(e) => {
                    let mut stream = update_stream_clone.lock().await;
                    stream.push(ClientUpdateData {
                        content: ClientUpdateContent::Data(DataContent {
                            content: format!("Login failed: {:?}", e),
                        }),
                    });
                }
            }
        });
    }
    #[func]
    fn check_stream(&mut self) {
        if let Some(session) = self.update_stream.as_ref() {
            let stream = self.runtime.block_on(async {
                let mut stream_lock = session.lock().await;
                stream_lock.drain(..).collect::<Vec<_>>()
            });

            if !stream.is_empty() {
                for update in stream {
                    match update.content {
                        ClientUpdateContent::Data(data) => {
                            godot_print!("Data received: {}", data.content);
                        }
                        ClientUpdateContent::Packet(packet) => {
                            godot_print!("Packet received: {:?}", packet);
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

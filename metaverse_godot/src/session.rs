use std::os::unix::net::UnixDatagram;
use std::path::PathBuf;

use actix_rt::Runtime;
use actix_rt::System;
use crossbeam::channel::unbounded;
use godot::classes::Control;
use godot::classes::IControl;
use godot::prelude::*;
use metaverse_messages::login_system::login::Login;
use metaverse_messages::packet::Packet;
use metaverse_session::client_subscriber::listen_for_server_events;
use metaverse_session::initialize::initialize;
use metaverse_messages::packet_types::PacketType;
use tempfile::NamedTempFile;
use crossbeam_channel::Receiver;

#[derive(GodotClass)]
#[class(base=Control)]
struct MetaverseSession {
    receiver: Receiver<PacketType>,
    base: Base<Control>,
    ui_to_server_socket: PathBuf,
}

#[godot_api]
impl IControl for MetaverseSession {
    fn init(base: Base<Control>) -> Self {
        // create temporary files
        let ui_to_server_socket = NamedTempFile::new()
            .expect("Failed to create temp file")
            .path()
            .to_path_buf();
        let server_to_ui_socket = NamedTempFile::new()
            .expect("Failed to create temp file")
            .path()
            .to_path_buf();
        let server_to_ui_socket_clone = server_to_ui_socket.clone();
        let ui_to_server_socket_clone = ui_to_server_socket.clone();

        let (sender, receiver) = unbounded();
        // start the actix process, and do not close the system until everything is finished
        std::thread::spawn(|| {
            System::new().block_on(async {
                match initialize(ui_to_server_socket, server_to_ui_socket).await {
                    Ok(handle) => {
                        match handle.await {
                            Ok(()) => godot_print!("Listener exited successfully!"),
                            Err(e) => godot_error!("Listener exited with error {:?}", e),
                        };
                    }
                    Err(err) => {
                        godot_error!("Failed to start client: {:?}", err);
                    }
                }
            });
        });

        std::thread::spawn(|| {
            let rt = Runtime::new().unwrap();
            rt.block_on(async {listen_for_server_events(server_to_ui_socket_clone, sender).await})
        });

        godot_print!("metaverse session started");
        Self { base,
        receiver,
            ui_to_server_socket: ui_to_server_socket_clone
        }
    }

    fn process(&mut self, _:f64) {
        while let Ok(event) = self.receiver.try_recv(){
            match event{
                PacketType::LoginResponse(login_response) => {
                    godot_print!("got login response: {:?}", login_response)
                }
                PacketType::CoarseLocationUpdate(coarse_location_update) => {
                    godot_print!("got coarse location update: {:?}", coarse_location_update)
                }
                PacketType::Error(error) => {
                    godot_error!("GOT ERROR!!! {:?}", error)
                }
                _ => {
                    godot_error!("not implemented yet")
                }
            }
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
    fn login(&self, first: String, last: String, passwd: String, url: String) {
        let url = if url == "localhost" {
            build_url("http://127.0.0.1", 9000)
        } else {
            "http".to_string()
        };

        let packet = Packet::new_login_packet(Login{
            first,
            last,
            passwd,
            url,
            channel: "benthic".to_string(),
            agree_to_tos: true, 
            read_critical: true,
            start: "home".to_string(),
        }).to_bytes();
        let client_socket = UnixDatagram::unbound().unwrap();
        match client_socket.send_to(&packet, &self.ui_to_server_socket) {
            Ok(_) => godot_print!("Login sent from UI"),
            Err(e) => godot_print!("Error sending login from UI {:?}", e),
        };
    }
}

fn build_url(url: &str, port: u16) -> String {
    let mut url_string = "".to_owned();
    url_string.push_str(url);
    url_string.push(':');
    url_string.push_str(&port.to_string());
    url_string
}

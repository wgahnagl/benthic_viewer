use std::os::unix::net::UnixDatagram;
use std::path::PathBuf;

use actix_rt::Runtime;
use actix_rt::System;
use crossbeam::channel::unbounded;
use crossbeam_channel::Receiver;
use godot::classes::Control;
use godot::classes::IControl;
use godot::obj::WithBaseField;
use godot::prelude::*;
use metaverse_messages::chat_from_viewer::ChatFromViewer;
use metaverse_messages::chat_from_viewer::ClientChatType;
use metaverse_messages::errors::SessionError;
use metaverse_messages::login_system::login::Login;
use metaverse_messages::login_system::login_response::LoginResponse;
use metaverse_messages::packet::Packet;
use metaverse_messages::packet_types::PacketType;
use metaverse_session::client_subscriber::listen_for_server_events;
use metaverse_session::initialize::initialize;
use tempfile::NamedTempFile;

#[derive(GodotClass)]
#[class(base=Control)]
struct MetaverseSession {
    receiver: Receiver<PacketType>,
    base: Base<Control>,
    login_response: Option<LoginResponse>,
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
            rt.block_on(async { listen_for_server_events(server_to_ui_socket_clone, sender).await })
        });

        godot_print!("metaverse session started");
        Self {
            base,
            receiver,
            ui_to_server_socket: ui_to_server_socket_clone,
            login_response: None,
        }
    }

    fn process(&mut self, _: f64) {
        while let Ok(event) = self.receiver.try_recv() {
            match event {
                PacketType::LoginResponse(login_response) => {
                        self.base_mut().emit_signal(
                            &StringName::from("login_response"),
                            &["Success".to_variant(), "".to_variant()],
                        );
                    self.login_response = Some(*login_response);
                }
                PacketType::CoarseLocationUpdate(coarse_location_update) => {
                    godot_print!("got coarse location update: {:?}", coarse_location_update)
                }
                PacketType::Error(error) => match *error {
                    SessionError::Login(e) => {
                        self.base_mut().emit_signal(
                            &StringName::from("login_response"),
                            &["Error".to_variant(), e.to_string().to_variant()],
                        );
                        godot_print!("should be emitted");
                        godot_error!("{:?}", e)
                    }
                    SessionError::Mailbox(e) => {
                        godot_error!("{:?}", e)
                    }
                    SessionError::AckError(e) => {
                        godot_error!("{:?}", e)
                    }
                    SessionError::CircuitCode(e) => {
                        godot_error!("{:?}", e)
                    }
                    SessionError::CompleteAgentMovement(e) => {
                        godot_error!("{:?}", e)
                    }
                },
                PacketType::ChatFromSimulator(chat) => {
                    let mut chat_from_self = false;
                    if Some(chat.owner_id) == self.login_response.clone().unwrap().agent_id{
                        chat_from_self = true;
                    }
                    self.base_mut().emit_signal(
                        &StringName::from("chat_from_simulator"),
                        &[chat.from_name.to_string().to_variant(),
                        chat.message.to_string().to_variant(),
                        chat_from_self.to_variant()]
                    );
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
    fn login_response(&self, message_type: String, message: String);

    #[signal]
    fn chat_from_simulator(&self, user:String, message:String, chat_from_self: bool);

    #[func]
    fn login(&self, first: String, last: String, passwd: String, url: String) {
        let url = if url == "localhost" {
            format!("{}:{}", "http://127.0.0.1", 9000)
        } else {
            format!("http://{}:{}", url, 9000)
        };

        let packet = Packet::new_login_packet(Login {
            first,
            last,
            passwd,
            url,
            channel: "benthic".to_string(),
            agree_to_tos: true,
            read_critical: true,
            start: "home".to_string(),
        })
        .to_bytes();
        let client_socket = UnixDatagram::unbound().unwrap();
        match client_socket.send_to(&packet, &self.ui_to_server_socket) {
            Ok(_) => godot_print!("Login sent from UI"),
            Err(e) => godot_print!("Error sending login from UI {:?}", e),
        };
    }

    #[func]
    fn send_chat(&self, message:String) {
        let login_response_clone = self.login_response.clone().unwrap();
        let packet = Packet::new_chat_from_viewer(ChatFromViewer{
            agent_id: login_response_clone.agent_id.unwrap(),
            session_id: login_response_clone.session_id.unwrap(),
            message_type: ClientChatType::Normal,
            channel: 0,
            message
        }).to_bytes();
        let client_socket = UnixDatagram::unbound().unwrap();
        match client_socket.send_to(&packet, &self.ui_to_server_socket) {
            Ok(_) => godot_print!("Chat sent from UI"),
            Err(e) => godot_print!("Error sending chat from UI {:?}", e),
        };
    }
}


use actix_rt::Runtime;
use actix_rt::System;
use crossbeam::channel::unbounded;
use crossbeam_channel::Receiver;
use crossbeam_channel::Sender;
use godot::classes::Control;
use godot::classes::IControl;
use godot::obj::WithBaseField;
use godot::prelude::*;
use log::info;
use log::warn;
use metaverse_core::initialize::initialize;
use metaverse_messages::packet::message::UIMessage;
use metaverse_messages::packet::message::UIResponse;
use metaverse_messages::udp::chat::ChatType;
use metaverse_messages::ui::chat_from_viewer::ChatFromUI;
use metaverse_messages::ui::errors::SessionError;
use metaverse_messages::ui::login_event::Login;
use metaverse_messages::ui::login_response::LoginResponse;
use portpicker::pick_unused_port;
use std::net::UdpSocket;

#[derive(GodotClass)]
#[class(base=Control)]
struct MetaverseSession {
    receiver: Receiver<UIMessage>,
    base: Base<Control>,
    login_response: Option<LoginResponse>,
    ui_to_server_socket: String,
}

pub async fn listen_for_core_events(core_to_ui_socket: String, sender: Sender<UIMessage>) {
    let socket = UdpSocket::bind(core_to_ui_socket).expect("Failed to bind UDP socket");

    info!("UI listening for core events on UDP: {:?}", socket);
    loop {
        let mut buf = [0u8; 1500];
        match socket.recv_from(&mut buf) {
            Ok((n, _)) => {
                if let Ok(packet) = UIMessage::from_bytes(&buf[..n]) {
                    // get the packet type and send that to the sender
                    if let Err(e) = sender.send(packet) {
                        warn!("Failed to send packet to UI: {:?}", e)
                    };
                }
            }
            Err(e) => {
                warn!("UI Failed to read buffer {}", e)
            }
        }
    }
}

#[godot_api]
impl IControl for MetaverseSession {
    fn init(base: Base<Control>) -> Self {
        let ui_to_core_socket = pick_unused_port().unwrap();
        let core_to_ui_socket = pick_unused_port().unwrap();

        let (sender, receiver) = unbounded();
        // start the actix process, and do not close the system until everything is finished
        std::thread::spawn(move || {
            System::new().block_on(async {
                match initialize(ui_to_core_socket, core_to_ui_socket).await {
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

        std::thread::spawn(move || {
            let rt = Runtime::new().unwrap();
            rt.block_on(async {
                listen_for_core_events(format!("127.0.0.1:{}", core_to_ui_socket), sender).await
            })
        });

        godot_print!("metaverse session started");
        Self {
            base,
            receiver,
            ui_to_server_socket: format!("127.0.0.1:{}", ui_to_core_socket),
            login_response: None,
        }
    }

    fn process(&mut self, _: f64) {
        while let Ok(event) = self.receiver.try_recv() {
            match event {
                UIMessage::LoginResponse(login_response) => {
                    self.base_mut().emit_signal(
                        &StringName::from("login_response"),
                        &["Success".to_variant(), "".to_variant()],
                    );
                    self.login_response = Some(login_response);
                }
                UIMessage::CoarseLocationUpdate(coarse_location_update) => {
                    godot_print!("got coarse location update: {:?}", coarse_location_update)
                }
                UIMessage::Error(error) => match error {
                    SessionError::Login(e) => {
                        self.base_mut().emit_signal(
                            &StringName::from("login_response"),
                            &["Error".to_variant(), e.to_string().to_variant()],
                        );
                        godot_print!("should be emitted");
                        godot_error!("{:?}", e)
                    }
                    SessionError::MailboxSession(e) => {
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
                    SessionError::Capability(e) => {
                        godot_error!("{:?}", e)
                    }
                    SessionError::FeatureError(e) => {
                        godot_error!("{:?}", e)
                    }
                    SessionError::IOError(e) => {
                        godot_error!("{:?}", e)
                    }
                },
                UIMessage::ChatFromSimulator(chat) => {
                    let mut chat_from_self = false;
                    if matches!(chat.chat_type, ChatType::StartTyping | ChatType::StopTyping) {
                        godot_print!("{:?} is typing...", chat.from_name);
                    } else {
                        if chat.owner_id == self.login_response.clone().unwrap().agent_id {
                            chat_from_self = true;
                        }
                        self.base_mut().emit_signal(
                            &StringName::from("chat_from_simulator"),
                            &[
                                chat.from_name.to_string().to_variant(),
                                chat.message.to_string().to_variant(),
                                chat_from_self.to_variant(),
                            ],
                        );
                    }
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
    fn chat_from_simulator(&self, user: String, message: String, chat_from_self: bool);

    #[func]
    fn login(&self, first: String, last: String, passwd: String, url: String) {
        let url = if url == "localhost" {
            format!("{}:{}", "http://127.0.0.1", 9000)
        } else {
            url
        };

        let packet = UIResponse::new_login_event(Login {
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
        let client_socket = UdpSocket::bind("0.0.0.0:0").unwrap();
        match client_socket.send_to(&packet, &self.ui_to_server_socket) {
            Ok(_) => godot_print!("Login sent from UI"),
            Err(e) => godot_print!("Error sending login from UI {:?}", e),
        };
    }

    #[func]
    fn send_chat(&self, message: String) {
        let packet = UIResponse::new_chat_from_viewer(ChatFromUI {
            message,
            message_type: ChatType::Normal,
            channel: 0,
        })
        .to_bytes();
        let client_socket = UdpSocket::bind("0.0.0.0:0").unwrap();
        match client_socket.send_to(&packet, &self.ui_to_server_socket) {
            Ok(_) => godot_print!("Chat sent from UI"),
            Err(e) => godot_print!("Error sending chat from UI {:?}", e),
        };
    }
}

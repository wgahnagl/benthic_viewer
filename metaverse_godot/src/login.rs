use actix::SystemRunner;
use godot::classes::ResourceLoader;
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
    runtime: SystemRunner,
    session: Option<Session>,
    current_scene: NodePath, 
}

#[godot_api]
impl IControl for MetaverseSession {
    fn init(base: Base<Control>) -> Self {
        let runtime = System::new();
        godot_print!("INITIALIZING METAVERSE SESSION");
        Self {
            base,
            runtime,
            session: None,
            current_scene: "res://res://login.tscn".into()
        }
    }

    fn process(&mut self, _: f64) {
        if let Some(session) = &self.session {
            let mut stream = session.update_stream.lock().unwrap();
            if !stream.is_empty() {
                for update in stream.drain(..) {
                    match update {
                        ClientUpdateData::Packet(packet) => {
                            godot_print!("Packet received: {:?}", packet);
                        }
                        ClientUpdateData::String(string) => {
                            godot_print!("String received: {:?}", string)
                        }
                        ClientUpdateData::Error(error) => {
                            godot_print!("Error received: {:?}", error);
                        }
                        ClientUpdateData::LoginProgress(login) => {
                            godot_print!("Login Progress received!!! {:?}", login)
                        }
                        ClientUpdateData::ChatFromSimulator(chat) => {
                            godot_print!("Chat received {:?}", chat)
                        }
                    }
                }
            }
        }
    }

    fn ready (&mut self ){
        self.switch_to_scene("res://login.tscn".into());

    }
}


#[godot_api]
impl MetaverseSession {
    #[signal]
    fn init_session();

    #[func]
    fn switch_to_scene(&mut self, scene_path: String){
        godot_print!("Switching scene to {:?}", scene_path);
        let current_scene_clone  = self.current_scene.clone();
        self.base_mut().get_node_or_null(current_scene_clone.clone());
        let current_scene = self.base().get_node_or_null(self.current_scene.clone());

        // If there's a current scene, remove it.
        if let Some(mut current_scene) = current_scene {
            self.base_mut().remove_child(current_scene.clone());
            current_scene.queue_free();
        }
        
        let scene_resource = ResourceLoader::singleton().load(scene_path.into());

        if let Some(scene) = scene_resource {
            let packed_scene = scene.cast::<PackedScene>();

                // Instantiate the new scene
                if let Some(mut new_scene) = packed_scene.instantiate() {
                    // Add the new scene as a child
                    self.base_mut().add_child(new_scene.clone());

                    // Name the new scene as "CurrentScene"
                    new_scene.set_name("CurrentScene".into());
                } else {
                    godot_error!("Failed to instantiate the scene");
                }
            } else {
                godot_error!("Failed to cast to PackedScene");
            }
        }


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

        let update_stream = Arc::new(Mutex::new(Vec::new()));

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
                update_stream.clone(),
            )
            .await;
            match result {
                Ok(session) => {
                    self.session = Some(session);
                    godot_print!("Login succeeded!");
                }
                Err(_) => {
                    godot_print!("Login failed");
                }
            }
        });

        // this should only be done on success
        self.switch_to_scene("res://chat.tscn".into());
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

pub mod session;
use godot::prelude::*;

struct MetaverseGodot;

#[gdextension]
unsafe impl ExtensionLibrary for MetaverseGodot {}

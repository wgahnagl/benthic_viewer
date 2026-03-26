extends Node3D
@onready var metaverse_session = get_tree().root.get_node("MetaverseSession") 

func _ready() -> void:
	metaverse_session.connect("land_update", _on_land_update)
	metaverse_session.connect("mesh_update", _on_mesh_update)
	
func _on_land_update(vertices: PackedVector3Array, indices: PackedInt32Array, land_position: Vector3):
	$Camera3D.position = Vector3(50, 50, 320)  
	$Camera3D.look_at(Vector3(0,0,0), Vector3.UP)

	var mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)

	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.3,0.7,0.3)
	mesh.surface_set_material(0, mat)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.surface_set_material(0, mat)

	var instance = MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = land_position
	instance.scale = Vector3(1,1,1)
	print(land_position)
	print("Land Rendered")
	add_child(instance)


func _on_mesh_update(path: String, position: Vector3, rotation: Vector3, scale: Vector3):
	print("Loading mesh (runtime): ", path)
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file(path, state)
	if err != OK:
		print("Failed to parse GLB: ", path)
		return
	var scene = doc.generate_scene(state)
	if scene == null:
		print("Failed to generate scene")
		return
	scene.position = position
	scene.rotation = rotation
	scene.scale = scale

	add_child(scene)

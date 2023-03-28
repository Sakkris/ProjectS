extends Node

var player
var current_line: MeshInstance3D
var material: StandardMaterial3D


func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	
	current_line = create_array_mesh(player.position, get_child(0).position)


func _process(delta):
	update_array_mesh(player.position, get_child(0).position)


func draw_line(pos1: Vector3, pos2: Vector3, color: Color = Color.MEDIUM_SPRING_GREEN) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	var material = ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = false
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	if current_line != null:
		current_line.queue_free()
	
	add_child(mesh_instance)
	
	current_line = mesh_instance
	
	return mesh_instance


func update_array_mesh(pos1: Vector3, pos2: Vector3):
	var arr_mesh: ArrayMesh = current_line.mesh
	
	var vertices = PackedVector3Array()
	vertices.push_back(pos1)
	vertices.push_back(pos2)
	
	var colors = PackedColorArray()
	
	for i in range(vertices.size()):
		colors.push_back(Color.MEDIUM_SPRING_GREEN)
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_COLOR] = colors
	
	arr_mesh.clear_surfaces()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	current_line.mesh = arr_mesh
	current_line.material_override = material


func create_array_mesh(pos1: Vector3, pos2: Vector3) -> MeshInstance3D:
	var vertices = PackedVector3Array()
	vertices.push_back(pos1)
	vertices.push_back(pos2)
	
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	var colors = PackedColorArray()
	
	for i in range(vertices.size()):
		colors.push_back(Color.MEDIUM_SPRING_GREEN)
	
	arrays[Mesh.ARRAY_COLOR] = colors
	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	var m = MeshInstance3D.new()
	
	m.mesh = arr_mesh
	m.material_override = material
	
	add_child(m)
	
	return m

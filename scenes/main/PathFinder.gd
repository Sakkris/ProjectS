extends Node

var player
var current_line: MeshInstance3D
var material: StandardMaterial3D
var destiny_node
var nav_points = []


func _ready():
	GameEvents.enemy_spawned.connect(on_enemy_spawned)
	
	player = get_tree().get_first_node_in_group("player")
	nav_points = get_children()
	
	material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	
	current_line = create_array_mesh(player.position, get_nearest_nav_point_to_node(player).position)


func _process(delta):
	update_array_mesh(player.position, get_nearest_nav_point_to_node(player).position)


func update_array_mesh(pos1: Vector3, pos2: Vector3):
	var arr_mesh: ArrayMesh = current_line.mesh
	var arrays = create_arrays(pos1, pos2)
	
	arr_mesh.clear_surfaces()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	current_line.mesh = arr_mesh
	current_line.material_override = material


func create_array_mesh(pos1: Vector3, pos2: Vector3) -> MeshInstance3D:
	var arr_mesh = ArrayMesh.new()
	var arrays = create_arrays(pos1, pos2)
	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	var m = MeshInstance3D.new()
	
	m.mesh = arr_mesh
	m.material_override = material
	
	add_child(m)
	
	return m


func create_arrays(pos1: Vector3, pos2: Vector3):
	var vertices = PackedVector3Array()
	vertices.push_back(pos1)
	vertices.push_back(pos2)
	
	if destiny_node != null:
		vertices.push_back(get_nearest_nav_point_to_node(destiny_node).position)
		vertices.push_back(destiny_node.position)
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	var colors = PackedColorArray()
	
	for i in range(vertices.size()):
		colors.push_back(Color.MEDIUM_SPRING_GREEN)
	
	arrays[Mesh.ARRAY_COLOR] = colors
	
	return arrays


func get_nearest_nav_point_to_node(node: Node3D) -> Node3D:
	var nearest_point
	var nearest_distance = 999.9
	var current_distance 
	
	for nav_point in nav_points:
		current_distance = nav_point.position.distance_squared_to(node.position)
		
		if current_distance < nearest_distance || nearest_point == null:
			nearest_distance = current_distance
			nearest_point = nav_point
	
	return nearest_point 


func on_enemy_spawned(enemy):
	destiny_node = enemy
















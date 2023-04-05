extends Node

var player
var current_line: MeshInstance3D
var material: StandardMaterial3D
var destiny_node
var nav_points = {}
var astar: AStar3D = AStar3D.new()


func _ready():
	GameEvents.enemy_spawned.connect(on_enemy_spawned)
	
	player = get_tree().get_first_node_in_group("player")
	
	var nav_points_nodes = get_children()
	var index = 0
	
	for nav_point in nav_points_nodes:
		nav_points[index] = nav_point
		index += 1
	
	material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	
	setup_astar()
	
	var orig_id = get_nearest_nav_point_to_node(player)
	var dest_id
	if destiny_node == null:
		dest_id = get_nearest_nav_point_to_node(player)
	else:
		dest_id = get_nearest_nav_point_to_node(destiny_node)
	
	current_line = create_array_mesh(orig_id, dest_id)


func _process(_delta):
	var orig_id = get_nearest_nav_point_to_node(player)
	var dest_id = get_nearest_nav_point_to_node(destiny_node)
	
	update_array_mesh(orig_id, dest_id)


func update_array_mesh(orig_id, dest_id):
	var arr_mesh: ArrayMesh = current_line.mesh
	var arrays = create_arrays(orig_id, dest_id)
	
	arr_mesh.clear_surfaces()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	current_line.mesh = arr_mesh
	current_line.material_override = material


func create_array_mesh(orig_id, dest_id) -> MeshInstance3D:
	var arr_mesh = ArrayMesh.new()
	var arrays = create_arrays(orig_id, dest_id)
	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	var m = MeshInstance3D.new()
	
	m.mesh = arr_mesh
	m.material_override = material
	
	add_child(m)
	
	return m


func create_arrays(orig_id, dest_id):
	var vertices = PackedVector3Array()
	var prev_vertice = null
	var id_path = astar.get_id_path(orig_id, dest_id)
	
	for point_id in id_path:
		if prev_vertice != null:
			vertices.push_back(nav_points[prev_vertice].position)
			vertices.push_back(nav_points[point_id].position)
		else: 
			vertices.push_back(player.position)
			vertices.push_back(nav_points[point_id].position)
		
		prev_vertice = point_id
	
	if destiny_node != null:
		vertices.push_back(nav_points[prev_vertice].position)
		vertices.push_back(destiny_node.position)
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	var colors = PackedColorArray()
	
	for i in range(vertices.size()):
		colors.push_back(Color.MEDIUM_SPRING_GREEN)
	
	arrays[Mesh.ARRAY_COLOR] = colors
	
	return arrays


func get_nearest_nav_point_to_node(node: Node3D):
	var nearest_point
	var nearest_distance = 999.9
	var current_distance 
	
	for nav_point in nav_points:
		current_distance = nav_points[nav_point].position.distance_squared_to(node.position)
		
		if current_distance < nearest_distance || nearest_point == null:
			nearest_distance = current_distance
			nearest_point = nav_point
	
	return nearest_point 


func get_connected_nav_points_to_point(point):
	var connected_points = [null, null]
	var nearest_distances = [999.9, 999.9]
	var current_distance = 0
	
	for nav_point in nav_points:
		if nav_point != point:
			current_distance = nav_points[nav_point].position.distance_squared_to(nav_points[point].position)
			
			if current_distance < nearest_distances[0] || connected_points[0] == null:
				nearest_distances[0] = current_distance
				connected_points[0] = nav_point
			elif current_distance < nearest_distances[1] || connected_points[1] == null:
					nearest_distances[1] = current_distance
					connected_points[1] = nav_point
	
	return connected_points


func add_astar_points():
	for nav_point in nav_points:
		astar.add_point(nav_point, nav_points[nav_point].position)


func make_astar_connections():
	var connected_points
	
	for nav_point in nav_points:
		connected_points = get_connected_nav_points_to_point(nav_point)
		
		astar.connect_points(nav_point, connected_points[0])
		astar.connect_points(nav_point, connected_points[1])


func setup_astar():
	add_astar_points()
	make_astar_connections()


func on_enemy_spawned(enemy):
	destiny_node = enemy

extends Node

@export var debug_lines: bool = false

var player
var current_line: MeshInstance3D
var material: StandardMaterial3D
var destiny_node
var astar: AStar3D = AStar3D.new()


func _ready():
	GameEvents.objective_created.connect(on_objective_created)

	player = get_tree().get_first_node_in_group("player")
	
	material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true

	setup_astar()
	NavPointGenerator.simplified_navigation = astar

	var orig_id = get_nearest_nav_point_to_node(player)
	var dest_id
	if destiny_node == null:
		dest_id = get_nearest_nav_point_to_node(player)
	else:
		dest_id = get_nearest_nav_point_to_node(destiny_node)

	current_line = create_array_mesh(orig_id, dest_id)


func _process(_delta):
	if destiny_node == null:
		return 

	var orig_id = get_nearest_nav_point_to_node(player)
	var dest_id = get_nearest_nav_point_to_node(destiny_node)

#	update_array_mesh(orig_id, dest_id)


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
			vertices.push_back(astar.get_point_position(prev_vertice))
			vertices.push_back(astar.get_point_position(point_id))
		else: 
			var player_position = player.position
			player_position.y += player.height / 2
			vertices.push_back(player_position)
			vertices.push_back(astar.get_point_position(point_id))
		
		prev_vertice = point_id
	
	if destiny_node != null:
		vertices.push_back(astar.get_point_position(prev_vertice))
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
	
	for nav_point in astar.get_point_ids():
		current_distance = astar.get_point_position(nav_point).distance_squared_to(node.position)
		
		if current_distance < nearest_distance || nearest_point == null:
			nearest_distance = current_distance
			nearest_point = nav_point
	
	return nearest_point 


func setup_astar():
	var vertices = PackedVector3Array()
	var children = get_children()
	
	for child in children:
		if child is NavigationPoint:
			if not astar.has_point(child.id):
				astar.add_point(child.id, child.global_position)
			
			for connected_point in child.connections:
				if not astar.has_point(connected_point.id):
					astar.add_point(connected_point.id, connected_point.global_position)

				if not astar.are_points_connected(child.id, connected_point.id):
					astar.connect_points(child.id, connected_point.id)
					
					if debug_lines:
						vertices.push_back(child.global_position)
						vertices.push_back(connected_point.global_position)
		
		if debug_lines:
			var arrays = []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = vertices
			
			var colors = PackedColorArray()
			
			for i in range(vertices.size()):
				colors.push_back(Color.MEDIUM_SPRING_GREEN)
			
			arrays[Mesh.ARRAY_COLOR] = colors
			
			var arr_mesh = ArrayMesh.new()
			arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
			var m = MeshInstance3D.new()
			
			m.mesh = arr_mesh
			m.material_override = material
			
			add_child(m)


func on_objective_created(objective):
	destiny_node = objective

extends Node3D

## This script utilizes Flood Fill to generate an AStar Node within an enclosed space that can then be used for navigation porpuses

@export_group("Generation Settings")

## an Hard Limit to how many points to check before returning (stops infinite loop in case there is a gap)
@export var limit = 9999

## The Directions to consider neighbours to each point
@export var considered_neighbours: possible_considered_neighbours =  possible_considered_neighbours.ONLY_SIDES

## Distance between each navigation point in meters
@export_range(0, 10, 1, "or_greater") var distance_between_points: int = 2

## The Collision Mask used by the raycasts to check for possible collisions
@export_flags_3d_physics var raycast_collision_mask: int = 0b0001

## Maximum Distance for each side the vector (0, 0, 0) disables this
@export var distance_limit = Vector3(0, 0, 0)

@export_group("JSON File")
## Creates a JSON File with the Navigation Points generated
@export var generate_json_file: bool = false

## Uses JSON File to load the navigation points, in case there is one
@export var use_json_file: bool = false

@export var file_path: String = "res://nav_points.json"

@export_group("Debug")
## Bool that defines if debug lines will be drawn representing the connections between navigation points
@export var draw_debug_lines: bool = false
## Bool that defines if debug meshes will be drawn representing the navigation points
@export var draw_debug_points: bool = false


enum possible_considered_neighbours {
	WITH_DIAGONALS = 26,
	ONLY_SIDES = 6
}

var direction_dict = {
	0: Vector3(1, 0, 0),
	1: Vector3(0, 1, 0),
	2: Vector3(0, 0, 1),
	3: Vector3(-1, 0, 0),
	4: Vector3(0, -1, 0),
	5: Vector3(0, 0, -1),
}

var astar: AStar3D = AStar3D.new()
var point_queue: Array[Vector3]
var space_state: PhysicsDirectSpaceState3D = null
var current_point: Vector3
var start_point: Vector3 = Vector3(0, 2, 0)

var material: StandardMaterial3D

var desired_point = null
var closest_point = null
var generated = false


func _ready():
	material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	
	if use_json_file && FileAccess.file_exists(file_path):
		if read_json_file():
			generated = true
			return
	
	point_queue.push_back(start_point)
	current_point = start_point


func _process(delta):
	if Engine.is_editor_hint():
		if FileAccess.file_exists(file_path):
			read_json_file()
		
	set_process(false)


# Generates a Astar Object giving it points and connections according to the settings defined,
# using a Flood Fill algorithm
func generate_astar():
	var idx = 0
	var point_id = 0
	
	space_state = get_world_3d().direct_space_state
	
	while not point_queue.is_empty():
		current_point = point_queue.pop_front()
		point_id = generate_point_id(current_point)
		astar.add_point(point_id, current_point)
		
		if idx > limit:
			break
		
		idx += 1
		
		for i in range(considered_neighbours):
			var target_point = current_point + direction_dict[i] * distance_between_points
			
			if distance_limit != Vector3.ZERO:
				if abs(target_point.x) > distance_limit.x || abs(target_point.y) > distance_limit.y || abs(target_point.z) > distance_limit.z:
					continue
			
			if not exists_obstacle_between(current_point, current_point + direction_dict[i] * distance_between_points * 1.1):
				
				var target_point_id = generate_point_id(target_point)
				
				if target_point_id < 0:
					printerr("Negative id ", target_point_id, " generated from: ", target_point)
				
				if astar.has_point(target_point_id):
					if not astar.are_points_connected(point_id, target_point_id):
						astar.connect_points(point_id, target_point_id)
						
						if draw_debug_lines:
							draw_debug_line(current_point, target_point)
				else:
					astar.add_point(target_point_id, target_point)
					astar.connect_points(point_id, target_point_id)
					point_queue.push_back(target_point)
					
					if draw_debug_lines:
						draw_debug_line(current_point, target_point)
					
					if draw_debug_points:
						draw_debug_point(target_point)
	
	generated = true
	
	if generate_json_file:
		generate_json()


# Generates an id from the point coordinates (Adaptation of szudzik pairing)
func generate_point_id(point: Vector3) -> int:
	# Convert the vector to a string and remove any spaces or parentheses
	var str_vec = str(point).replace(" ", "").replace("(", "").replace(")", "")

	# Convert the string to a unique integer using a hash function
	var id = hash(str_vec) & 0x7FFFFFFF
	
	# Ensure the ID is positive
	if id < 0:
		id += 0x7FFFFFFF + 1
	
	return id


# Queries a Raycast between the origin_point and the target_point and checks for any collision
func exists_obstacle_between(origin_point: Vector3, target_point: Vector3) -> bool:
	var query = PhysicsRayQueryParameters3D.create(origin_point, target_point)
	
	query.collision_mask = raycast_collision_mask
	query.hit_from_inside = true
	query.hit_back_faces = true
	
	var result = space_state.intersect_ray(query)
	
	return not result.is_empty()


# Finds the closest point in the AStar to the desired position
func get_closest_point(desired_point_pos: Vector3) -> Vector3:
	var x_pos: int = get_closest_coordinate(desired_point_pos.x)
	var y_pos: int = get_closest_coordinate(desired_point_pos.y)
	var z_pos: int = get_closest_coordinate(desired_point_pos.z) 
	var point = Vector3(x_pos, y_pos, z_pos)
	
	if astar.has_point(generate_point_id(point)):
		return point
	
	var attempt_limit = 5
	var attempt = 0
	var attempted_point
	
	while attempt_limit > attempt:
		for i in range(considered_neighbours):
			attempted_point = point + direction_dict[i] * (distance_between_points * attempt)
			
			if astar.has_point(generate_point_id(attempted_point)):
				return attempted_point
		
		attempt += 1
	
	return start_point


# Calculates the closest coordinate that is part of the navigation grid 
# Example: If the distance between points is 2 this will return the closest number to 'coordinate'
#             that is multiple of 2
func get_closest_coordinate(coordinate) -> int:
	if roundi(coordinate) % distance_between_points == 0: 
		return roundi(coordinate)
	else:
		if coordinate < 0:
			coordinate = abs(coordinate)
			return -(((floori(coordinate) + distance_between_points/2) / distance_between_points) * distance_between_points)
		
		return ((floori(coordinate) + distance_between_points / 2) / distance_between_points) * distance_between_points


func generate_path(origin: Vector3, destiny: Vector3) -> PackedVector3Array:
	origin = get_closest_point(origin)
	var path_origin_id = generate_point_id(origin)
	
	destiny = get_closest_point(destiny)
	var path_dest_id = generate_point_id(destiny)
	
	return astar.get_point_path(path_origin_id, path_dest_id)


# Generates a JSON file with the navigation points
func generate_json():
	var json_dictionary = {}
	
	for point_id in astar.get_point_ids():
		var point_dictionary = {}
		var coordinates = astar.get_point_position(point_id)
		var connections = astar.get_point_connections(point_id)
		
		point_dictionary["coordinates"] = coordinates
		point_dictionary["connections"] = connections
		
		json_dictionary[point_id] = point_dictionary
	
	var json_string = JSON.stringify(json_dictionary, "\t")
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()


func read_json_file() -> bool:
	var json_file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = json_file.get_as_text()
	var data = JSON.parse_string(json_string)
	
	if data == null:
		return false
	
	var str_vec
	var int_point_id
	var int_connection
	for point_id in data:
		int_point_id = int(point_id)
		var point_dictionary = data[point_id]
		
		if not astar.has_point(int_point_id):
			str_vec = str(point_dictionary["coordinates"]).replace(" ", "").replace("(", "").replace(")", "").split(",")
			var point_position = Vector3(float(str_vec[0]), float(str_vec[1]), float(str_vec[2]))
			
			astar.add_point(int_point_id, point_position)
			
			if draw_debug_points || Engine.is_editor_hint():
				draw_debug_point(point_position)
		
		for connection in point_dictionary["connections"]:
			int_connection = int(connection)
			
			if astar.has_point(int_connection) && not astar.are_points_connected(int_point_id, int_connection):
				astar.connect_points(int_point_id, int_connection)
				
				if draw_debug_lines:
						draw_debug_line(astar.get_point_position(int_point_id), astar.get_point_position(int_connection))
	
	print(astar.get_point_count())
	json_file.close()
	return true


# Draws a debug line between the two given points
func draw_debug_line(orig_point, dest_point):
	var vertices = PackedVector3Array()
	
	vertices.push_back(orig_point)
	vertices.push_back(dest_point)
	
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
	
	m.visibility_range_end
	m.mesh = arr_mesh
	m.material_override = material
	
	add_child(m)


# Draws a debug mesh in the given position
func draw_debug_point(point: Vector3, point_material = material, point_size = Vector3(.3, .3, .3)):
	var myMesh: MeshInstance3D = MeshInstance3D.new()
	
	myMesh.mesh = BoxMesh.new()
	myMesh.visibility_range_end = 20.0
	myMesh.mesh.size = point_size
	myMesh.material_override = point_material
	add_child(myMesh)
	myMesh.position = point
	return myMesh

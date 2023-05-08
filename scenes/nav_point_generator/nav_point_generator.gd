extends Node3D
class_name NavPointGenerator

enum possible_considered_neighbours {
	WITH_DIAGONALS = 26,
	ONLY_SIDES = 6
}

@export_category("Generation Options")
# An Hard Limit to how many points to check before returning (stops infinite loop in case there is a gap)
@export var limit = 9999

# The Directions to consider neighbours to each point
@export var considered_neighbours: possible_considered_neighbours =  possible_considered_neighbours.ONLY_SIDES

# Distance between each navigation point in meters
@export_range(0, 10, 1, "or_greater") var distance_between_points: int = 2

# The Collision Mask used by the raycasts to check for possible collisions
@export_flags_3d_physics var raycast_collision_mask: int = 0b0001

# Maximum Distance for each side the vector (0, 0, 0) disables this
@export var distance_limit = Vector3(0, 0, 0)

@export_category("Debug")
@export var draw_debug_lines: bool = false
@export var draw_debug_points: bool = false

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

var controller: XRController3D
var desired_point = null
var closest_point = null

func _ready():
	material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	point_queue.push_back(start_point)
	
	await owner.ready
	controller = $"../Player/XROrigin3D/RightController"


func _physics_process(delta):
	if !point_queue.is_empty():
		generate_astar()
	
	if controller.is_button_pressed("by_button"):
		if desired_point != null:
			desired_point.queue_free()
			closest_point.queue_free()
		
		var desired_position = controller.global_position
		var desired_point_mat = StandardMaterial3D.new()
		desired_point_mat.albedo_color = Color.GOLD
		
		desired_point = draw_debug_point(desired_position, desired_point_mat, Vector3(0.1, 0.1, 0.1))
		
		var closest_position = get_closest_point(desired_position)
		var closest_point_mat = StandardMaterial3D.new()
		closest_point_mat.albedo_color = Color.GREEN
		
		closest_point = draw_debug_point(closest_position, closest_point_mat, Vector3(0.1, 0.1, 0.1))


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
			
			if not exists_obstacle_between(current_point, target_point):
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


# Queries a Raycast between the current_point and the target_point and checks for any collision
func exists_obstacle_between(current_point: Vector3, target_point: Vector3) -> bool:
	var query = PhysicsRayQueryParameters3D.create(current_point, target_point)
	
	query.collision_mask = raycast_collision_mask
	query.hit_from_inside = true
	query.hit_back_faces = true
	
	var result = space_state.intersect_ray(query)
	
	return not result.is_empty()


func get_closest_point(desired_point: Vector3) -> Vector3:
	var x_pos: int = get_closest_coordinate(desired_point.x)
	var y_pos: int = get_closest_coordinate(desired_point.y)
	var z_pos: int = get_closest_coordinate(desired_point.z) 
	
	print(desired_point, " | ", Vector3(x_pos, y_pos, z_pos))
	
	return Vector3(x_pos, y_pos, z_pos)


func get_closest_coordinate(coordinate) -> int:
	if roundi(coordinate) % distance_between_points == 0: 
		return roundi(coordinate)
	else:
		if coordinate < 0:
			coordinate = abs(coordinate)
			return -(((floori(coordinate) + distance_between_points/2) / distance_between_points) * distance_between_points)
		
		return ((floori(coordinate) + distance_between_points/2) / distance_between_points) * distance_between_points



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
	
	m.mesh = arr_mesh
	m.material_override = material
	
	add_child(m)

func draw_debug_point(point: Vector3, point_material = material, point_size = Vector3(0.05, 0.05, 0.05)):
	var myMesh: MeshInstance3D = MeshInstance3D.new()
	myMesh.mesh = BoxMesh.new()
	myMesh.mesh.size = point_size
	myMesh.material_override = point_material
	add_child(myMesh)
	myMesh.position = point
	return myMesh

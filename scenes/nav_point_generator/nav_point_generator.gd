
extends Node3D
class_name NavPointGenerator

enum possible_considered_neighbours {
	WITH_DIAGONALS = 26,
	ONLY_SIDES = 6
}

# The Directions to consider neighbours to each point
@export var considered_neighbours: possible_considered_neighbours =  possible_considered_neighbours.ONLY_SIDES

# Distance between each navigation point in meters
@export_range(0, 10, 1, "or_greater") var distance_between_points: float = 2

# The Collision Mask used by the raycasts to check for possible collisions
@export_flags_3d_physics var raycast_collision_mask: int = 0b0001

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

var generated: bool = false

func _process(delta):
	if Engine.is_editor_hint():
		generate_astar()
		set_process(false)


func generate_astar():
	var limit = 10
	var idx = 0
	space_state = get_world_3d().direct_space_state
	point_queue.push_back(Vector3.UP)
	
	var point_id = 0
	point_id = generate_point_id(current_point)
	astar.add_point(point_id, current_point)
	
	while not point_queue.is_empty():
		current_point = point_queue.pop_back()
		
		if idx > limit:
			return
		
		for i in range(considered_neighbours):
			var target_point = current_point + direction_dict[i] * distance_between_points
			
			if not exists_obstacle_between(current_point, target_point):
				var target_point_id = generate_point_id(target_point)
				
				if astar.has_point(target_point_id):
					if not astar.are_points_connected(point_id, target_point_id):
						astar.connect_points(point_id, target_point_id)
				else:
					astar.add_point(target_point_id, target_point)
					astar.connect_points(point_id, target_point_id)
					point_queue.push_back(target_point)
		idx += 1


# Generates an id from the point coordinates (Adaptation of szudzik pairing)
func generate_point_id(point: Vector3) -> int:
	if point.x >= point.y:
		if point.y >= point.z:
			return point.x * point.x + point.x + point.y
		elif point.x >= point.z:
			return point.x * point.x + point.x + point.z
		else:
			return point.z * point.z + point.y
	else:
		if point.x >= point.z:
			return point.y * point.y + point.y + point.x
		elif point.y >= point.z:
			return point.y * point.y + point.y + point.z
		else:
			return point.z * point.z + point.y


# Queries a Raycast between the current_point and the target_point and checks for any collision
func exists_obstacle_between(current_point: Vector3, target_point: Vector3) -> bool:
	var query = PhysicsRayQueryParameters3D.create(current_point, target_point)
	
	query.collision_mask = raycast_collision_mask
	query.hit_from_inside = true
	query.hit_back_faces = true
	
	var result = space_state.intersect_ray(query)
	
	print(result)
	
	return not result.is_empty()

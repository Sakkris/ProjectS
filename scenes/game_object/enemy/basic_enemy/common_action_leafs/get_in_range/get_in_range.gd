class_name GetInRange extends ActionLeaf

@export var show_debug_line: bool = false
@export var is_obstacle_between_checker: ConditionLeaf
@export var teleport_ideal_distance: int = 5

@onready var path_cd_timer: Timer = $Timer

var process_tick = true
var cd_base_time

var current_line: MeshInstance3D
var material: StandardMaterial3D

func _ready():
	cd_base_time = path_cd_timer.wait_time
	
	material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true


func tick(actor: Node, blackboard: Blackboard) -> int:
	if !NavPointGenerator.generated:
		return FAILURE
	
	if actor.attack_range > actor.distance_to_player:
		if is_obstacle_between_checker:
			is_obstacle_between_checker.tick(actor, blackboard)
			
			if not blackboard.get_value("has_obstacle"):
				return SUCCESS
		else: 
			return SUCCESS
	
	if not actor.update_path_queued && actor.path_to_follow.size() > 0:
		actor.path_to_follow[actor.path_to_follow.size() - 1] = actor.player.global_position
		
		return RUNNING
	
	actor.update_path_queued = false
	
	if actor.detection_range < actor.distance_to_player:
		if !path_cd_timer.is_stopped():
			return RUNNING
		
		if actor.distance_to_player > 50:
			define_simple_path(actor)
			
			if actor.path_to_follow.size() == 0:
				actor.update_path_queued = true
				return RUNNING
		else:
			define_path(actor)
		
		path_cd_timer.wait_time = cd_base_time + randf() - 0.5
		path_cd_timer.start()
		
		return RUNNING
	
	if process_tick:
		define_path(actor)
	
	process_tick = !process_tick
	return RUNNING


func define_simple_path(actor):
	var start_position: Vector3 = actor.global_position
	var player_position = actor.player.global_position
	var path: PackedVector3Array
	
	if actor.path_to_follow.size() == 0 || not is_same_direction(actor.global_position, actor.path_to_follow[0], player_position):
		start_position = actor.global_position
	else:
		path = actor.path_to_follow.slice(actor.current_target_index, actor.path_to_follow.size() - 1)
		path.resize(path.size() / 2)
		
		if path.size() == 0:
			start_position = actor.global_position
		else:
			start_position = path[path.size() - 1]
	
	path.append_array(NavPointGenerator.generate_simple_path(start_position, player_position))
	
	if path.size() > teleport_ideal_distance:
		path = teleport_drone_near_player(actor, path)
	
	if is_same_direction(actor.global_position, path[0], path[1]):
		actor.current_target_index = -1
	else:
		actor.current_target_index = 0
	
	actor.path_to_follow = path
	actor.next_target_point()
	
	if show_debug_line:
		if current_line:
			update_array_mesh(path, actor)
		else:
			current_line = create_line_mesh(path, actor)


func teleport_drone_near_player(actor, path: PackedVector3Array):
	if randf() > .6:
		var rand_number = randi_range(1, 3)
		var ideal_point = path[teleport_ideal_distance - rand_number]
		var next_point = path[teleport_ideal_distance - rand_number + 1]
		
		var teleport_position: Vector3 = randf() * (ideal_point - next_point) + ideal_point
		
		actor.global_position = teleport_position
		
		return path.slice(path.size() - teleport_ideal_distance + 1)
	
	var objective = get_tree().get_first_node_in_group("objective")
	var random_direction = Vector3.UP.rotated(Vector3.FORWARD, randf_range(0.0, 2.0 * PI))
	var teleport_position = objective.global_position - random_direction * 2
	
	actor.global_position = teleport_position
	
	path.clear()
	return path


func define_path(actor):
	var start_position: Vector3
	var player_position = actor.player.global_position
	var path: PackedVector3Array
	
	if actor.path_to_follow.size() == 0 || not is_same_direction(actor.global_position, actor.path_to_follow[actor.current_target_index], player_position):
		start_position = actor.global_position
	else:
		path = actor.path_to_follow.slice(actor.current_target_index, actor.path_to_follow.size() - 1)
		path.resize(path.size() / 2)
		
		if path.size() == 0:
			start_position = actor.global_position
		else:
			start_position = path[path.size() - 1]
	
	actor.current_target_index = -1
	
	path.append_array(NavPointGenerator.generate_path(start_position, player_position))
	
	path.push_back(actor.player.global_position)
	
	actor.path_to_follow = path
	actor.next_target_point()
	
	if show_debug_line:
		if current_line:
			update_array_mesh(path, actor)
		else:
			current_line = create_line_mesh(path, actor)


func is_same_direction(center_position: Vector3, position1: Vector3, position2: Vector3) -> bool:
	var vec1 = center_position.direction_to(position1)
	var vec2 = center_position.direction_to(position2)
	
	return vec1.dot(vec2) > 0.0
 

func update_array_mesh(path: PackedVector3Array, actor):
	var arr_mesh: ArrayMesh = current_line.mesh
	var arrays = create_line_arrays(path, actor)
	
	arr_mesh.clear_surfaces()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	current_line.mesh = arr_mesh
	current_line.material_override = material


func create_line_mesh(path: PackedVector3Array, actor) -> MeshInstance3D:
	var arr_mesh = ArrayMesh.new()
	var arrays = create_line_arrays(path, actor)
	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	var m = MeshInstance3D.new()
	
	m.mesh = arr_mesh
	m.material_override = material
	
	get_tree().get_first_node_in_group("Debugger").add_child(m)
	
	return m


func create_line_arrays(path: PackedVector3Array, actor):
	var vertices = PackedVector3Array()
	var prev_vertice = null
	
	for point in path:
		if prev_vertice != null:
			vertices.push_back(prev_vertice)
			vertices.push_back(point)
		else: 
			vertices.push_back(actor.global_position)
			vertices.push_back(point)
		
		prev_vertice = point
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	var colors = PackedColorArray()
	
	for i in range(vertices.size()):
		colors.push_back(Color.ORANGE_RED)
	
	arrays[Mesh.ARRAY_COLOR] = colors
	
	return arrays

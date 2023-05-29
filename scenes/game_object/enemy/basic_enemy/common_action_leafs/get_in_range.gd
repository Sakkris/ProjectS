class_name GetInRange extends ActionLeaf

@export var attack_range: Area3D

@onready var path_cd_timer: Timer = $Timer

var process_tick = true
var cd_base_time

var current_line: MeshInstance3D
var material: StandardMaterial3D

func _ready():
	cd_base_time = path_cd_timer.wait_time
	
	material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if !NavPointGenerator.generated:
		return FAILURE
	
	if actor.attack_range > actor.distance_to_player:
		return SUCCESS
	
	if not actor.update_path_queued && actor.path_to_follow.size() > 0:
		actor.path_to_follow[actor.path_to_follow.size() - 1] = actor.player.global_position
		
		return RUNNING
	
	actor.update_path_queued = false
	
	if actor.detection_range < actor.distance_to_player:
		if !path_cd_timer.is_stopped():
			return RUNNING
		
		path_cd_timer.wait_time = cd_base_time + randf() - 0.5
		path_cd_timer.start()
		
		define_path(actor)
		return RUNNING
	
	if process_tick:
		define_path(actor)
	
	process_tick = !process_tick
	return RUNNING


func define_path(actor):
	var start_position: Vector3
	var player_position = actor.player.global_position
	var path: PackedVector3Array
	
	if actor.path_to_follow.size() == 0:
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
	
#	if current_line:
#		update_array_mesh(path, actor)
#	else:
#		current_line = create_line_mesh(path, actor)


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
		colors.push_back(Color.MEDIUM_SPRING_GREEN)
	
	arrays[Mesh.ARRAY_COLOR] = colors
	
	return arrays

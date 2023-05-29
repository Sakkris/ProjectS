class_name GetInRange extends ActionLeaf

@export var attack_range: Area3D

@onready var path_cd_timer: Timer = $Timer

var process_tick = true
var cd_base_time

func _ready():
	cd_base_time = path_cd_timer.wait_time


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
		path = actor.path_to_follow
		path.resize(path.size() / 2)
		start_position = path[path.size() - 1]
	
	path.append_array(NavPointGenerator.generate_path(start_position, player_position))
	
	path.push_back(actor.player.global_position)

	actor.path_to_follow = path
	actor.current_target_index = -1
	actor.next_target_point()

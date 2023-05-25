class_name GetInRange extends ActionLeaf

@export var attack_range: Area3D

@onready var path_cd_timer: Timer = $Timer

var process_tick = true


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if !NavPointGenerator.generated:
		return FAILURE
	
	if actor.attack_range > actor.distance_to_player:
		return SUCCESS
	
	if actor.detection_range < actor.distance_to_player:
		if !path_cd_timer.is_stopped():
			return RUNNING
		
		path_cd_timer.start()
		
		define_path(actor)
		return RUNNING
	
	if process_tick:
		define_path(actor)
	
	process_tick = !process_tick
	return RUNNING


func define_path(actor):
	var current_location = actor.global_position
	var player_location = actor.player.global_position
	
	var path: PackedVector3Array = NavPointGenerator.generate_path(current_location, player_location)
	path.append(actor.player.global_position)

	actor.path_to_follow = path
	actor.current_target_index = -1
	actor.next_target_point()

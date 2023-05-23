class_name GetInRange extends ActionLeaf

@export var attack_range: Area3D

var debug_points: Array 
var debug_lines: Array


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if !NavPointGenerator.generated:
		return FAILURE
	
	if actor.attack_range > actor.distance_to_player:
		return SUCCESS
	
	var current_location = actor.global_position
	var player_location = actor.player.global_position
	
	var path: PackedVector3Array = NavPointGenerator.generate_path(current_location, player_location)
	path.append(actor.player.global_position)
	
	actor.path_to_follow = path
	actor.current_target_index = -1
	actor.next_target_point()
	return RUNNING



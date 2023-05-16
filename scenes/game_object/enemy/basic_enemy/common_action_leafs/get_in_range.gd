class_name GetInRange extends ActionLeaf

@export var detection_range: Area3D

@onready var path_cooldown_timer = $Timer

var debug_points: Array 
var debug_lines: Array

func tick(actor: Node, blackboard: Blackboard) -> int:
	if !NavPointGenerator.generated:
		return FAILURE
	
	if detection_range.has_overlapping_areas() || detection_range.has_overlapping_bodies():
		actor.target_point = actor.player.global_transform.origin
		return SUCCESS
	
	var current_location = actor.global_position
	var player_location = owner.player.global_position
#	var is_player_far = current_location.distance_squared_to(player_location) >= 20 ** 2
	
	if !path_cooldown_timer.is_stopped(): #&& is_player_far:
		return SUCCESS
	
	var path: PackedVector3Array = NavPointGenerator.generate_path(current_location, player_location)
	
	path.append(actor.player.global_transform.origin)
	
#	if is_player_far:
	path_cooldown_timer.start()
	
	actor.path_to_follow = path
	actor.current_target_index = 0
	actor.next_target_point()
	return SUCCESS



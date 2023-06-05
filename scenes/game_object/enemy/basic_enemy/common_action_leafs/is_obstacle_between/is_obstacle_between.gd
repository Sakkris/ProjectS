extends ConditionLeaf

@export_flags_3d_physics var raycast_collision_mask 


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.space_state == null:
		return SUCCESS
	
	var query = PhysicsRayQueryParameters3D.create(actor.global_position, actor.player.global_position)
	
	query.collision_mask = raycast_collision_mask
	
	var result = actor.space_state.intersect_ray(query)
	
	if result.is_empty():
		blackboard.set_value("has_obstacle", false)
		return FAILURE
	
	blackboard.set_value("has_obstacle", true)
	return SUCCESS

extends ConditionLeaf

@export_flags_3d_physics var raycast_collision_mask 


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var query = PhysicsRayQueryParameters3D.create(actor.global_transform.origin, actor.player.global_transform_origin)
	
	query.collision_mask = raycast_collision_mask
	
	var result = actor.space_state.intersect_ray(query)
	
	print("Checking obstacle")
	print(result)
	if NavPointGenerator.exists_obstacle_between(actor.global_transform.origin, actor.player.global_transform_origin):
		print("obstacle detected")
		return SUCCESS

	return FAILURE

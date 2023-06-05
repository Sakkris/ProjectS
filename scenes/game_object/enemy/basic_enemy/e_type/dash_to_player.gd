extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("dir_to_target") == Vector3.ZERO:
		var dir_to_target = actor.global_transform.origin.direction_to(blackboard.get_value("target")).normalized()
		
		actor.dashing = true
		actor.dash_vector = dir_to_target * actor.dash_speed
		
		blackboard.set_value("dir_to_target", dir_to_target)
	
	var distance = actor.global_transform.origin.distance_to(blackboard.get_value("target"))
	
	if distance < 2:
		return SUCCESS
	
	return RUNNING

extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.dash_attack(blackboard.get_value("target"))
	
	var distance = actor.global_transform.origin.distance_to(blackboard.get_value("target"))
	
	if distance < .5:
		actor.end_dash()
		return SUCCESS
	
	return RUNNING

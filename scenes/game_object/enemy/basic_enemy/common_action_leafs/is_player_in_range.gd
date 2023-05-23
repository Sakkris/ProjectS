extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.attack_range > actor.distance_to_player:
		return SUCCESS
	
	return FAILURE

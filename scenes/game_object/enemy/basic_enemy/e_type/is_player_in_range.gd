extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var distance = actor.get_distance_to_player()
	
	if distance <= actor.attack_range:
		return SUCCESS
	
	return FAILURE

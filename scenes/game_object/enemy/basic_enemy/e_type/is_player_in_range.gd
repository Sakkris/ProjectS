extends ConditionLeaf

@export var attack_range: Area3D 


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if attack_range.has_overlapping_areas() || attack_range.has_overlapping_bodies():
		return SUCCESS
	
	return FAILURE

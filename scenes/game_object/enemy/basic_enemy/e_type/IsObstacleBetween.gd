extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
#	print("Checking obstacle")
#	if NavPointGenerator.exists_obstacle_between(actor.global_transform.origin, actor.player.global_transform_origin):
#		print("obstacle detected")
#		return SUCCESS
#
	return FAILURE

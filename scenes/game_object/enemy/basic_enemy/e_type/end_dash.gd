extends ActionLeaf

var transition_animation = "engage_transition"
var idle_animation = "idle"


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.die_on_dash:
		actor.call_deferred("explode")
		return SUCCESS
	
	actor.velocity_component.velocity = blackboard.get_value("dir_to_target") * actor.dash_speed / 2.0
	actor.play_inverse_animation(transition_animation, idle_animation)
	
	actor.dashing = false
	blackboard.set_value("target", Vector3.ZERO)
	blackboard.set_value("dir_to_target", Vector3.ZERO)
	
	return SUCCESS

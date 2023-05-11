extends ActionLeaf

var transition_animation = "engage_transition"

func tick(actor: Node, blackboard: Blackboard) -> int:
	if !$Timer.is_stopped():
		return SUCCESS
	
	actor.full_stop()
	actor.look_at_player()
	blackboard.set_value("target", actor.player.global_transform.origin)
	
	if !actor.animation_player.is_playing():
		$Timer.start()
		return FAILURE
	
	actor.play_animation(transition_animation)
	
	return RUNNING

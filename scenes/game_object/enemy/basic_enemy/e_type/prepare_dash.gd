extends ActionLeaf

var transition_animation = "engage_transition"

func tick(actor: Node, blackboard: Blackboard) -> int:
	if !$Timer.is_stopped():
		return SUCCESS
	
	actor.full_stop()
	actor.look_at_player()
	blackboard.set_value("target", actor.player.global_position)
	
	if (actor.animation_player and !actor.animation_player.is_playing()) or actor.animation_player == null:
		$Timer.start()
		return FAILURE
	
	actor.play_animation(transition_animation)
	
	return RUNNING

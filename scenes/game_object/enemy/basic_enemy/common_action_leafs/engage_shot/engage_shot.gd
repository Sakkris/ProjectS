extends ActionLeaf

var transition_animation = "engage_transition"


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.full_stop()
	actor.look_at_player()
	
	actor.path_to_follow.clear()
	actor.current_target_index = -1
	
	if actor.animation_player == null || !actor.animation_player.is_playing():
		blackboard.set_value("is_engaged", true)
		return SUCCESS
	
	if !actor.is_animation_playing(transition_animation):
		actor.play_animation(transition_animation)
	
	return RUNNING

extends ActionLeaf

var transition_animation = "engage_transition"


func tick(actor: Node, blackboard: Blackboard) -> int:
	if !$DashCooldown.is_stopped():
		return SUCCESS
	
	actor.full_stop()
	actor.look_at_player()
	
	var target_point = actor.player.global_position
	target_point.y += actor.player.height / 2
	
	blackboard.set_value("target", target_point)
	
	if (actor.animation_player and !actor.animation_player.is_playing()) or actor.animation_player == null:
		$DashCooldown.start()
		return FAILURE
	
	actor.play_animation(transition_animation)
	
	return RUNNING

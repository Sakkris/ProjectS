extends ActionLeaf

var transition_animation = "engage_transition"
var idle_animation = "idle"
var is_playing = false


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.full_stop()
	actor.look_at_player()
	
	if not blackboard.get_value("is_engaged"):
		return FAILURE
	
	if actor.animation_player == null || (!actor.is_animation_playing(transition_animation) && is_playing):
		blackboard.set_value("is_engaged", false)
		is_playing = false
		return SUCCESS
	
	if !actor.is_animation_playing(transition_animation):
		actor.play_inverse_animation(transition_animation, idle_animation)
		is_playing = true
	
	return RUNNING

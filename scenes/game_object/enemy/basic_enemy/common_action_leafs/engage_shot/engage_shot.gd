extends ActionLeaf

@export var lock_on_audio: AudioStreamPlayer3D

var transition_animation = "engage_transition"
var first_pass = true


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.full_stop()
	actor.look_at_player()
	
	actor.path_to_follow.clear()
	actor.current_target_index = -1
	
	if actor.animation_player == null || !actor.animation_player.is_playing() && not lock_on_audio.playing:
		blackboard.set_value("is_engaged", true)
		first_pass = true
		return SUCCESS
	
	if first_pass:
		actor.play_animation(transition_animation)
		lock_on_audio.play()
		first_pass = false
	
	return RUNNING

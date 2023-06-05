extends ActionLeaf

@export var lost_player_audio: AudioStreamPlayer3D

var transition_animation = "engage_transition"
var idle_animation = "idle"
var first_pass = true


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.full_stop()
	actor.look_at_player()
	
	if not blackboard.get_value("is_engaged"):
		return FAILURE
	
	if actor.animation_player == null || (!actor.is_animation_playing(transition_animation) && !lost_player_audio.playing && !first_pass):
		blackboard.set_value("is_engaged", false)
		first_pass = true
		return SUCCESS
	
	if first_pass:
		actor.play_inverse_animation(transition_animation, idle_animation)
		lost_player_audio.play()
		first_pass = false
	
	return RUNNING

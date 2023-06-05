extends ActionLeaf

@export var lock_on_audio: AudioStreamPlayer3D

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
		if not lock_on_audio.playing:
			$DashCooldown.start()
			lock_on_audio.stop()
			return FAILURE
	
	if lock_on_audio && not lock_on_audio.playing:
		lock_on_audio.play()
		actor.play_animation(transition_animation)
	
	return RUNNING

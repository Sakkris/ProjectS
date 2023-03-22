extends Node

var is_braking: bool = false
var player_velocity_component: VelocityComponent


func _ready():
	GameEvents.start_braking_request.connect(on_start_braking_request)
	GameEvents.stop_braking_request.connect(on_stop_braking_request)
	
	player_velocity_component = get_tree().get_first_node_in_group("player").get_node("VelocityComponent")


func _physics_process(delta):
	if not is_braking:
		return
	
	player_velocity_component.decelerate(delta)


func on_start_braking_request():
	is_braking = true


func on_stop_braking_request():
	is_braking = false

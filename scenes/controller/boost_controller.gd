extends Node

var is_boosting: bool = false
var player_velocity_component: VelocityComponent


func _ready():
	GameEvents.start_boosting_request.connect(on_start_boosting_request)
	GameEvents.stop_boosting_request.connect(on_stop_boosting_request)
	
	player_velocity_component = get_tree().get_first_node_in_group("player").get_node("VelocityComponent")


func _physics_process(delta):
	if not is_boosting:
		return
	
	player_velocity_component.accelerate(delta)


func on_start_boosting_request(controller_id):
	is_boosting = true


func on_stop_boosting_request(controller_id):
	is_boosting = false

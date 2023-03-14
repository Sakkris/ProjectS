extends Node

@export var thruster_force: float = 1

var controller_id
var controller
var is_thrusting: bool = false


func _ready():
	GameEvents.start_thrusting_request.connect(on_start_thrusting_request)
	GameEvents.stop_thrusting_request.connect(on_stop_thrusting_request)
	controller_id = get_parent().controller_id


func _physics_process(delta):
	if is_thrusting:
		thrust(delta)


func thrust(delta):
	if controller == null:
		get_controller()
		if controller == null:
			return
	
	var basis = controller.global_transform.basis
	var player_velocity_component = get_tree().get_first_node_in_group("player").get_node("VelocityComponent")
	
	player_velocity_component.accelerate_in_direction(-basis.z * thruster_force, delta)


func get_controller():
	var controllers = get_tree().get_nodes_in_group("controller")
	
	for current_controller in controllers:
		if current_controller.get_tracker_hand() == self.controller_id:
			controller = current_controller
			break


func on_start_thrusting_request(signal_controller_id):
	if controller_id == signal_controller_id:
		is_thrusting = true


func on_stop_thrusting_request(signal_controller_id):
	if controller_id == signal_controller_id:
		is_thrusting = false

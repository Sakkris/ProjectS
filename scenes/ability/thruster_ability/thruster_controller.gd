extends Node

@onready var start_recharge_timer = $StartRechargeTimer

@export var thruster_force: float = 1
@export var max_charge: float = 100
@export var discharge_rate: float = 20 
@export var recharge_rate: float = 30

var controller_id
var controller
var current_charge 
var is_thrusting: bool = false
var is_charging: bool = false


func _ready():
	GameEvents.start_thrusting_request.connect(on_start_thrusting_request)
	GameEvents.stop_thrusting_request.connect(on_stop_thrusting_request)
	
	start_recharge_timer.timeout.connect(on_start_recharge_timer_timeout)
	
	controller_id = get_parent().controller_id
	current_charge = max_charge


func _physics_process(delta):
	if is_thrusting:
		thrust(delta)
	if is_charging:
		recharge(delta)


func thrust(delta):
	if controller == null:
		get_controller()
		if controller == null:
			return
	
	if is_zero_approx(current_charge):
		return
	
	var basis = controller.global_transform.basis
	var player_velocity_component = get_tree().get_first_node_in_group("player").get_node("VelocityComponent")
	
	player_velocity_component.accelerate_in_direction(-basis.z * thruster_force, delta)
	
	current_charge -= discharge_rate * delta
	GameEvents.emit_player_thruster_updated(controller_id, current_charge, max_charge)


func recharge(delta):
	if is_equal_approx(current_charge, max_charge):
		is_charging = false
		return
	
	current_charge += recharge_rate * delta
	GameEvents.emit_player_thruster_updated(controller_id, current_charge, max_charge)


func get_controller():
	var controllers = get_tree().get_nodes_in_group("controller")
	
	for current_controller in controllers:
		if current_controller.get_tracker_hand() == self.controller_id:
			controller = current_controller
			break


func on_start_thrusting_request(signal_controller_id):
	if controller_id == signal_controller_id:
		is_thrusting = true
		is_charging = false
		start_recharge_timer.stop()


func on_stop_thrusting_request(signal_controller_id):
	if controller_id == signal_controller_id:
		is_thrusting = false
		start_recharge_timer.start()


func on_start_recharge_timer_timeout():
	is_charging = true

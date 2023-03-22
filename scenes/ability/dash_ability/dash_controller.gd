extends Node

@onready var cooldown_timer: Timer = $DashCooldownTimer

@export var dash_force: float = 10

var can_dash: bool = true
var controller_id
var controller
var cooldown_left


func _ready():
	GameEvents.dash_request.connect(on_dash_request)
	
	cooldown_timer.timeout.connect(on_cooldown_timer_timeout)
	
	controller_id = get_parent().controller_id


func _process(delta):
	if !can_dash:
		cooldown_left = cooldown_timer.wait_time - cooldown_timer.time_left
		GameEvents.emit_player_dash_updated(controller_id, cooldown_left, cooldown_timer.wait_time)


func dash():
	if controller == null:
		get_controller()
		if controller == null:
			return
	
	if !can_dash:
		return
	
	var basis = controller.global_transform.basis
	var player_velocity_component: VelocityComponent = get_tree().get_first_node_in_group("player").get_node("VelocityComponent")
	
	player_velocity_component.reset_if_opposite_velocity(-basis.z)
	
	player_velocity_component.velocity += -basis.z * dash_force
	
	start_cooldown()


func start_cooldown():
	cooldown_timer.start()
	can_dash = false


func get_controller():
	var controllers = get_tree().get_nodes_in_group("controller")
	
	for current_controller in controllers:
		if current_controller.get_tracker_hand() == self.controller_id:
			controller = current_controller
			break


func on_dash_request(signal_controller_id):
	if controller_id == signal_controller_id:
		dash()


func on_cooldown_timer_timeout():
	can_dash = true

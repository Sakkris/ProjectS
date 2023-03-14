extends Node

@export var dash_force: float = 2

var controller_id
var controller


func _ready():
	GameEvents.dash_request.connect(on_dash_request)
	controller_id = get_parent().controller_id


func dash():
	if controller == null:
		get_controller()
		if controller == null:
			return
	
	var basis = controller.global_transform.basis
	var player_velocity_component = get_tree().get_first_node_in_group("player").get_node("VelocityComponent")
	var current_velocity = player_velocity_component.velocity
	
	if is_same_general_direction(-basis.z, current_velocity):
		player_velocity_component.velocity += -basis.z * dash_force
	else:
		player_velocity_component.velocity = -basis.z * dash_force


func get_controller():
	var controllers = get_tree().get_nodes_in_group("controller")
	
	for current_controller in controllers:
		if current_controller.get_tracker_hand() == self.controller_id:
			controller = current_controller
			break


# Verifica se os dois vetores estão na mesma direção geral (até um máximo de 45º de diferença)
func is_same_general_direction(dash_vector: Vector3, velocity_vector: Vector3) -> bool:
	var dash_norm = dash_vector.normalized()
	var velocity_norm = velocity_vector.normalized()
	
	return dash_norm.dot(velocity_norm) > 0.5 


func on_dash_request(signal_controller_id):
	if controller_id == signal_controller_id:
		dash()

extends Node

@export var dash_force: float = 4

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
	var player = get_tree().get_first_node_in_group("player")
	player.velocity = -basis.z * dash_force


func get_controller():
	var controllers = get_tree().get_nodes_in_group("controller")
	
	for current_controller in controllers:
		if current_controller.get_tracker_hand() == self.controller_id:
			controller = current_controller
			break


func on_dash_request(controller_id):
	if self.controller_id == controller_id:
		dash()

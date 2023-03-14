extends Node

@onready var hook = $Hook
@onready var hook_line: CSGCylinder3D = $%Line

@export var hook_max_lenght: float = 15

enum states {HOOKING, COLLIDING, RETRACTING}

var current_state
var controller_id
var controller


func _ready():
	GameEvents.start_hooking_request.connect(on_start_hooking_request)
	GameEvents.stop_hooking_request.connect(on_stop_hooking_request)
	
	controller_id = get_parent().controller_id


func _physics_process(delta):
	if controller == null:
		controller = get_controller_node()
		
		if controller == null:
			return
		
		place_hook_on_controller()
	
	match (current_state):
		states.HOOKING:
			throw_hook(delta)
		states.COLLIDING:
			pass
		states.RETRACTING:
			retract_hook(delta)
		_:
			pass


func get_controller_node():
	var controllers = get_tree().get_nodes_in_group("controller")
	
	for controller in controllers:
		if controller.get_tracker_hand() == controller_id:
			return controller
	
	return null


func retract_hook(delta):
	hook_line.height -= 0.5 * delta


func throw_hook(delta):
	hook_line.height += 0.2 * delta


func place_hook_on_controller():
	pass


func on_start_hooking_request(signal_controller_id: int):
	if signal_controller_id == controller_id:
		current_state = states.HOOKING


func on_stop_hooking_request(signal_controller_id: int):
	if signal_controller_id == controller_id:
		current_state = states.RETRACTING

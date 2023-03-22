extends Node

signal hook_finished_retracting

@export var hook_scene: PackedScene

var controller_id
var controller
var hook_instance
var gun_nuzzle
var is_hooking: bool = false

func _ready():
	GameEvents.start_hooking_request.connect(on_start_hooking_request)
	GameEvents.stop_hooking_request.connect(on_stop_hooking_request)
	
	controller_id = get_parent().controller_id


func _physics_process(_delta):
	if is_hooking:
		hook_instance.player_gun_nuzzle = gun_nuzzle 


func get_controller_node():
	var controllers = get_tree().get_nodes_in_group("controller")
	
	for current_controller in controllers:
		if current_controller.get_tracker_hand() == controller_id:
			gun_nuzzle = current_controller.get_node("GunNuzzle")
			
			return current_controller
	
	return null


func retract_hook():
	hook_instance.change_state(hook_instance.states.RETRACTING)


func throw_hook():
	hook_instance = hook_scene.instantiate()
	hook_instance.player_gun_nuzzle = controller.get_node("GunNuzzle")
	hook_instance.global_transform = hook_instance.player_gun_nuzzle.global_transform
	hook_instance.change_state(hook_instance.states.HOOKING)
	hook_instance.hook_finished_retracting.connect(on_hook_finished_retracting)
	
	get_tree().get_first_node_in_group("projectile_manager").add_child(hook_instance)


func on_start_hooking_request(signal_controller_id: int):
	if signal_controller_id == controller_id:
		if controller == null:
			controller = get_controller_node()
			
			if controller == null:
				return
		
		throw_hook()


func on_stop_hooking_request(signal_controller_id: int):
	if signal_controller_id == controller_id:
		if controller == null:
			controller = get_controller_node()
			
			if controller == null:
				return
		
		retract_hook()


func on_hook_finished_retracting():
	GameEvents.emit_hook_finished_retracting(controller_id)

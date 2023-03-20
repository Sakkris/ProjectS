extends Node

@onready var _averager := XRToolsVelocityAveragerLinear.new(5)

var player: CharacterBody3D
var player_velocity_component: VelocityComponent
var grab_area: Area3D
var grab_area_collision: CollisionShape3D
var controller: XRController3D
var controller_id
var is_grabbing = false
var grab_position: Vector3


func _ready():
	GameEvents.start_grabbing_request.connect(on_start_grabbing_request)
	GameEvents.stop_grabbing_request.connect(on_stop_grabbing_request)
	controller_id = get_parent().controller_id
	
	controller = get_parent().get_parent() as XRController3D
	grab_area = controller.get_node("GrabArea") as Area3D
	grab_area_collision = grab_area.get_node("CollisionShape3D") as CollisionShape3D
	
	grab_area.body_entered.connect(on_body_entered)
	
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	player_velocity_component = player.get_node("VelocityComponent") as VelocityComponent


func _physics_process(delta):
	if not is_grabbing:
		return
	
	var offset_movement = Vector3.ZERO
	var current_position = controller.global_transform.origin
	
	offset_movement =  grab_position - current_position
	
	player_velocity_component.full_stop()
	player.move_and_collide(offset_movement)
	
	_averager.add_distance(delta, offset_movement)
	
	return true


func on_start_grabbing_request(signal_controller_id: int):
	if controller_id == signal_controller_id:
		grab_area_collision.disabled = false


func on_stop_grabbing_request(signal_controller_id: int):
	if controller_id == signal_controller_id:
		grab_area_collision.disabled = true
		is_grabbing = false
		player_velocity_component.velocity = _averager.velocity()
		player_velocity_component.can_move = true


func on_body_entered(other_body):
	grab_position = controller.global_transform.origin
	is_grabbing = true
	_averager.clear()
	player_velocity_component.can_move = false

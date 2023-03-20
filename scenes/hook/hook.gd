extends Node3D
class_name Hook

signal hook_finished_retracting

const HOOK_THROW_SPEED = 30.0
const HOOK_PULL_SPEED = 5.0
const HOOK_RETRACT_SPEED = 40.0

@export var hook_max_length: float = 25

@onready var hook_tip = $HookTip
@onready var hook_line_origin = $LineOrigin
@onready var hook_line = $%Line

var player_gun_nuzzle: Node3D

enum states {HOOKING, COLLIDING, RETRACTING}

var started_colliding = false
var current_state
var last_length = 0
var colliding_body = null
var player_velocity_component: VelocityComponent


func _ready():
	$HookTip/Area3D.body_entered.connect(on_body_entered)
	
	player_velocity_component = get_tree().get_first_node_in_group("player").get_node("VelocityComponent")
	
	hook_line_origin.scale.z = 0
	hook_line.visible = true


func _physics_process(delta):
	#$GunNuzzle.global_transform = player_gun_nuzzle.global_transform
	draw_line()
	
	
	match current_state:
		states.HOOKING:
			throw_hook(delta)
		states.COLLIDING:
			go_to_colliding_body(delta)
		states.RETRACTING:
			retract_hook(delta)


func throw_hook(delta):
	if not are_numbers_close(hook_current_length(), hook_max_length):
		hook_tip.global_translate(transform.basis.z * -HOOK_THROW_SPEED * delta)
		
		if hook_current_length() > hook_max_length:
			var distance_overshot = hook_current_length() - hook_max_length
			#print("Distance: ", hook_current_length(), " / Overshot:", distance_overshot)
			
			hook_tip.global_translate(Vector3.BACK * distance_overshot)
			
			#print("New Distance: ", hook_current_length())
		
		last_length = hook_current_length()
	else:
		change_state(states.RETRACTING)


func retract_hook(delta):
	if last_length > 0:
		var direction = hook_tip.global_transform.origin.direction_to(player_gun_nuzzle.global_transform.origin)
		
		hook_tip.global_translate(direction * HOOK_RETRACT_SPEED * delta)
		
		last_length -= last_length - hook_current_length() 
		
		if are_numbers_close(last_length, 0):
			hook_tip.global_translate(Vector3.FORWARD * hook_current_length())
			last_length = 0
	else:
		hook_finished_retracting.emit()
		queue_free()


func go_to_colliding_body(delta):
	var direction = player_gun_nuzzle.global_position.direction_to(hook_tip.global_position)
	
	if started_colliding:
		player_velocity_component.reset_if_opposite_velocity(direction)
		started_colliding = false
	
	player_velocity_component.accelerate_in_direction(direction * HOOK_PULL_SPEED, delta)
	
	if hook_current_length() < 1:
		change_state(states.RETRACTING)


func draw_line():
	if hook_current_length() == 0:
		return
	
	hook_line_origin.global_transform = player_gun_nuzzle.global_transform
	hook_line_origin.look_at(hook_tip.global_transform.origin, player_gun_nuzzle.global_transform.basis.y)
	hook_line_origin.scale.z = hook_current_length()
	


func change_state(new_state):
	if current_state == states.COLLIDING:
		colliding_body = null
	
	if new_state == states.RETRACTING:
		call_deferred("disable_collision")
	
	current_state = new_state


func hook_current_length() -> float:
	return hook_tip.global_transform.origin.distance_to(player_gun_nuzzle.global_transform.origin)


func are_numbers_close(number1: float, number2: float) -> float:
	return number2 - 0.8 < number1 && number1 < number2 + 0.8


func disable_collision():
	$HookTip/Area3D/CollisionShape3D.disabled = true


func on_body_entered(other_body):
	change_state(states.COLLIDING)
	started_colliding = true
	call_deferred("disable_collision")
	colliding_body = other_body

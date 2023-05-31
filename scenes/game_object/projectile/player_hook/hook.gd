extends Node3D
class_name Hook

signal finished_retracting

const HOOK_THROW_SPEED = 60.0
const HOOK_PULL_SPEED = 10.0
const HOOK_RETRACT_SPEED = 50.0

@export var hook_max_length: float = 40 
@export var acceleration_curve: Curve

@onready var hook_tip = $HookTip
@onready var hook_line_origin = $LineOrigin
@onready var hook_line = $%Line
@onready var hit_particles = $HitParticles

enum states {HOOKING, COLLIDING, RETRACTING}

var current_acceleration: float = 0.0
var acceleration_offset: float = 0.0
var current_state
var last_length = 0
var origin


func _ready():
	$HookTip/Area3D.body_entered.connect(on_body_entered)
	
	origin = global_transform.origin
	hook_line_origin.scale.z = 0
	hook_line.visible = true


func update(delta) -> bool:
	draw_line()
	
	match current_state:
		states.HOOKING:
			throw_hook(delta)
		states.COLLIDING:
			if hook_current_length() < 1:
				change_state(states.RETRACTING)
			
			acceleration_offset = min(acceleration_offset + delta, 1)
			current_acceleration = HOOK_PULL_SPEED * acceleration_curve.sample(acceleration_offset)
			
			return true
		states.RETRACTING:
			retract_hook(delta)
	
	return false


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
		var direction = hook_tip.global_transform.origin.direction_to(origin.global_transform.origin)
		
		hook_tip.global_translate(direction * HOOK_RETRACT_SPEED * delta)
		
		last_length -= last_length - hook_current_length() 
		
		if are_numbers_close(last_length, 0):
			hook_tip.global_translate(Vector3.FORWARD * hook_current_length())
			last_length = 0
	else:
		emit_finished_retracting()
		queue_free()


func draw_line():
	if hook_current_length() == 0:
		return
	
	hook_line_origin.global_transform = origin.global_transform
	hook_line_origin.look_at(hook_tip.global_transform.origin, origin.global_transform.basis.y)
	hook_line_origin.scale.z = hook_current_length()


func change_state(new_state):
	if new_state == states.RETRACTING:
		call_deferred("disable_collision")
	
	current_state = new_state


func hook_current_length() -> float:
	return hook_tip.global_transform.origin.distance_to(origin.global_transform.origin)


func are_numbers_close(number1: float, number2: float) -> float:
	return number2 - 0.8 < number1 && number1 < number2 + 0.8


func disable_collision():
	$HookTip/Area3D/CollisionShape3D.disabled = true


func emit_finished_retracting():
	finished_retracting.emit()


func on_body_entered(_other_body):
	change_state(states.COLLIDING)
	hit_particles.position = hook_tip.position
	hit_particles.emitting = true
	call_deferred("disable_collision")

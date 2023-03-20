extends Node
class_name VelocityComponent

@onready var parent_node: CharacterBody3D = get_parent()

@export var max_speed: float = 10
@export var max_overloaded_speed: float = 15
@export var acceleration_coeficient: float = .2

var velocity: Vector3
var can_move: bool = true


func move(delta):
	if !can_move:
		return 
	
	if exceeds_max_speed():
		decelerate_to_max_speed(delta)
	
	parent_node.velocity = velocity
	parent_node.move_and_slide()
	#print("Current Speed: ", velocity.length(), "m/s")


func accelerate(delta):
	velocity = velocity.lerp(velocity.normalized() * max_speed, 1.0 - exp(-acceleration_coeficient * delta))


func decelerate(delta):
	accelerate_to_velocity(Vector3.ZERO, delta)


func decelerate_to_max_speed(delta):
	if not exceeds_max_speed():
		return
	
	accelerate_to_velocity(calculate_max_velocity(), delta)


func exceeds_max_speed():
	return velocity.length() > max_speed


func accelerate_to_velocity(target_velocity: Vector3, delta):
	velocity = velocity.lerp(target_velocity, 1.0 - exp(-acceleration_coeficient * delta))


func accelerate_in_direction(direction: Vector3, delta):
	velocity += direction * delta
	
	if velocity.length() > max_overloaded_speed:
		velocity = calculate_max_velocity()


func calculate_max_velocity() -> Vector3:
	return velocity.normalized() * max_speed


func calculate_max_overloaded_velocity() -> Vector3:
	return velocity.normalized() * max_overloaded_speed


func reset_if_opposite_velocity(direction: Vector3):
	var direction_norm = direction.normalized()
	var velocity_norm = velocity.normalized()
	
	if direction_norm.dot(velocity_norm) <= 0.5:
		full_stop() 

func full_stop():
	velocity = Vector3.ZERO

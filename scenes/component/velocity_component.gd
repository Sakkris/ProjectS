extends Node
class_name VelocityComponent

@onready var parent_node: CharacterBody3D = get_parent()

@export var max_speed: float = 10
@export var acceleration_coeficient: float = .2

var velocity: Vector3


func move(delta):
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
	
	if velocity.length() > max_speed:
		velocity = calculate_max_velocity()


func calculate_max_velocity() -> Vector3:
	return velocity.normalized() * max_speed


func stop():
	pass

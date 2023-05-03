extends Node
class_name VelocityComponent

@onready var parent_node: CharacterBody3D = get_parent()

@export var max_speed: float = 10
@export var max_overloaded_speed: float = 15
@export var acceleration_coeficient: float = .5

var velocity: Vector3
var can_move: bool = true


func move(delta):
	if !can_move:
		return 
	
	if exceeds_max_speed():
		decelerate_to_max_speed(delta)
	
	parent_node.velocity = velocity
	var collision = parent_node.move_and_collide(velocity * delta)
	
	if collision:
		var collision_normal = collision.get_normal()
		
		if velocity.normalized().dot(collision_normal) <= -0.7:
			velocity = velocity.bounce(collision_normal) / 20.0
		else:
			velocity = velocity.slide(collision_normal)
	#print("Current Speed: ", velocity.length(), "m/s")


func fixed_movement(movement: Vector3):
	parent_node.move_and_collide(movement)


func accelerate(delta):
	velocity = velocity.lerp(calculate_max_velocity(), 1.0 - exp(-acceleration_coeficient * delta))


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
		velocity = calculate_max_overloaded_velocity()


func calculate_max_velocity() -> Vector3:
	return velocity.normalized() * max_speed


func calculate_max_overloaded_velocity() -> Vector3:
	return velocity.normalized() * max_overloaded_speed


func change_direction(new_direction: Vector3):
	var direction_norm = new_direction.normalized()
	velocity = velocity.length() * direction_norm


func reset_if_opposite_velocity(direction: Vector3):
	var direction_norm = direction.normalized()
	var velocity_norm = velocity.normalized()
	
	if direction_norm.dot(velocity_norm) <= 0:
		full_stop() 


func full_stop():
	velocity = Vector3.ZERO

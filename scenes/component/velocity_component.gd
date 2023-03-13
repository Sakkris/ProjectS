extends Node
class_name VelocityComponent

@export var max_speed: float = 10
@export var acceleration_coeficient: float = .2

var velocity: Vector3


func accelerate(delta):
	velocity = velocity.lerp(velocity.normalized() * max_speed, 1.0 - exp(-acceleration_coeficient * delta))


func decelerate(delta):
	accelerate_to_velocity(Vector3.ZERO, delta)


func accelerate_to_velocity(target_velocity: Vector3, delta):
	velocity = velocity.lerp(target_velocity, 1.0 - exp(-acceleration_coeficient * delta))


func accelerate_in_direction(direction: Vector3):
	pass


func stop():
	pass

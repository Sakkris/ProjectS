extends Node

@export var max_speed: float = 5
@export var acceleration_coeficient: float = .5

var velocity: Vector3


func accelerate():
	velocity = velocity.lerp(velocity, 1.0 - exp(-acceleration_coeficient))


func decelerate():
	accelerate_to_velocity(Vector3.ZERO)


func accelerate_to_velocity(target_velocity: Vector3):
	velocity = velocity.lerp(velocity, 1.0 - exp(-acceleration_coeficient))


func accelerate_in_direction(direction: Vector3):
	pass


func stop():
	pass

extends Ability

signal gun_shot(controller_id)

@export var bullet_scene: PackedScene

@onready var gun: Gun = $Gun


func use():
	gun.nuzzle = gun_nuzzle
	gun.start_shooting()


func stop():
	gun.stop_shooting()


func reset():
	gun.reset()

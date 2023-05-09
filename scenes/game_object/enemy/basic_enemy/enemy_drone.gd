extends CharacterBody3D

@export var navigation_generator: Node

const SPEED = 2.0

var player: Player = null
var direction = transform.basis * Vector3.LEFT
var turn_flag = 1


func _ready():
	$Hurtbox.area_entered.connect(self.on_hit_taken)


func _physics_process(_delta):
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
#	move_and_slide()


func on_hit_taken(_area):
	GameEvents.emit_enemy_died()
	queue_free()

extends CharacterBody3D

const SPEED = 2.0

var direction = transform.basis * Vector3.LEFT
var turn_flag = 1


func _ready():
	$Timer.timeout.connect(self.on_timer_timeout)
	$Hurtbox.area_entered.connect(self.on_hit_taken)


func _physics_process(_delta):
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
#	move_and_slide()


func on_timer_timeout():
	if turn_flag:
		direction = transform.basis * Vector3.RIGHT
		turn_flag = 0
	else:
		direction = transform.basis * Vector3.LEFT
		turn_flag = 1


func on_hit_taken(_area):
	GameEvents.emit_enemy_died()
	queue_free()

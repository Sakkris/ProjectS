extends CharacterBody3D


const SPEED = 2.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
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
	queue_free()

extends Area3D

const BULLET_SPEED = 30.0


func _ready():
	$BulletLifeTime.timeout.connect(self.on_lifetime_timeout)


func _process(delta):
	global_translate(transform.basis.z * -BULLET_SPEED * delta)


func on_lifetime_timeout():
	queue_free()

extends Area3D

@onready var hit_particles: CPUParticles3D = $HitParticles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var bullet_speed = 50.0

func _ready():
	$BulletLifeTime.timeout.connect(self.on_lifetime_timeout)
	area_entered.connect(on_area_entered)
	body_entered.connect(on_body_entered)


func _physics_process(delta):
	global_translate(transform.basis.z * -bullet_speed * delta)


func hit_target():
	bullet_speed = 0
	$AnimationPlayer.play("hit")

func on_lifetime_timeout():
	hit_target()


func on_area_entered(_other_area):
	hit_target()


func on_body_entered(_other_body):
	hit_target()

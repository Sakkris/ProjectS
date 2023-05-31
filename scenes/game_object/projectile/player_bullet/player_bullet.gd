extends Area3D

@export var bullet_speed = 100.0

@onready var hit_particles: CPUParticles3D = $HitParticles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var space_state = null
var prev_pos


func _ready():
	$BulletLifeTime.timeout.connect(self.on_lifetime_timeout)
	area_entered.connect(on_area_entered)
	body_entered.connect(on_body_entered)


func _physics_process(delta):
	space_state = get_world_3d().direct_space_state
	global_translate(transform.basis.z * -bullet_speed * delta)
	
	if prev_pos != null:
		var query = PhysicsRayQueryParameters3D.create(prev_pos, global_position)
		query.collision_mask = collision_mask
		query.hit_from_inside = true
		query.hit_back_faces = true
		var result = space_state.intersect_ray(query)
		
		if not result.is_empty():
			global_position = result.position
		
	prev_pos = global_position


func hit_target():
	bullet_speed = 0
	$AnimationPlayer.play("hit")


func on_lifetime_timeout():
	hit_target()


func on_area_entered(_other_area):
	hit_target()


func on_body_entered(_other_body):
	hit_target()

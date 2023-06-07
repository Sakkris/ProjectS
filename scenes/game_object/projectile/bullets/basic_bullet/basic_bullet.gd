extends Area3D

@export var bullet_speed = 100.0
@export var check_previous_positions: bool = false

@onready var hit_particles: CPUParticles3D = $HitParticles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var space_state = null
var prev_pos: Array[Vector3]
var pos_buffer = 0
var pos_index = 0
var first_pass = true


func _ready():
	$BulletLifeTime.timeout.connect(self.on_lifetime_timeout)
	area_entered.connect(on_area_entered)
	body_entered.connect(on_body_entered)
	
	if check_previous_positions:
		prev_pos.resize(5)
		prev_pos.insert(0, global_position)


func _physics_process(delta):
	space_state = get_world_3d().direct_space_state
	global_translate(transform.basis.z * -bullet_speed * delta)
	
	if check_previous_positions:
		if prev_pos != null:
			var query = PhysicsRayQueryParameters3D.create(prev_pos[pos_index], global_position)
			query.collision_mask = collision_mask
			query.hit_from_inside = true
			query.hit_back_faces = true
			var result = space_state.intersect_ray(query)
			
			if not result.is_empty():
				global_position = result.position
		
		pos_buffer += 1
		if pos_buffer > prev_pos.size() - 1:
			pos_buffer = 0
			
			if first_pass:
				first_pass = false
		
		prev_pos.insert(pos_buffer, global_position)
		
		if !first_pass:
			pos_index += 1
			if pos_index > prev_pos.size() - 1:
				pos_index = 0


func hit_target():
	bullet_speed = 0
	$AnimationPlayer.play("hit")


func on_lifetime_timeout():
	hit_target()


func on_area_entered(_other_area):
	hit_target()


func on_body_entered(_other_body):
	hit_target()

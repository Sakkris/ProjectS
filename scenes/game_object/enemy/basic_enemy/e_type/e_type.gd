extends EnemyDrone

@export var dash_speed = 20
@export var die_on_dash: bool = false

@onready var explosion_radius: CollisionShape3D = $ExplosionRadius/CollisionShape3D

var dashing = false
var dashing_target = Vector3.ZERO


func _ready():
	$Hurtbox.area_entered.connect(self.on_hit_taken)
	
	if player:
		player.closest_nav_point_changed.connect(self.on_player_moved)
	
#	$DroneMesh/bad_Ship/main_body.visibility_range_begin = 0
#	$DroneMesh/bad_Ship/main_body.visibility_range_end = 10
#	$MeshInstance3D.visibility_range_begin = 10


func _physics_process(delta):
	if !dash_check(delta):
		movement_process(delta)
	
	if detection_range > distance_to_player:
		look_at_player()
	
	velocity_component.move(delta)


func tick():
	space_state = get_world_3d().direct_space_state
	distance_to_player = global_position.distance_to(player.global_position)
	behavior_tree.tick()


func dash_check(delta) -> bool:
	if dashing && dashing_target != Vector3.ZERO:
		var dir_to_target = global_transform.origin.direction_to(dashing_target).normalized()
		velocity_component.fixed_movement(dir_to_target * dash_speed * delta)
		
		return true
	
	return false


func dash_attack(target: Vector3):
	dashing = true
	dashing_target = target
	
	var dir_to_target = global_position.direction_to(dashing_target).normalized()
	velocity = dir_to_target * dash_speed / 2.0


func end_dash():
	if die_on_dash:
		call_deferred("explode")
	
	dashing = false
	dashing_target = Vector3.ZERO
	
	if animation_player:
		animation_player.play_backwards("engage_transition")
		animation_player.queue("idle")
	
	velocity_component.velocity = velocity


func explode():
	explosion_radius.disabled = false
	call_deferred("death")

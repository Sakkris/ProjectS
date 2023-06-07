extends EnemyDrone

@export var dash_speed = 20
@export var die_on_dash: bool = false

@onready var explosion_radius: CollisionShape3D = $ExplosionRadius/CollisionShape3D

var dashing = false
var dash_vector = Vector3.ZERO


func _ready():
	$Hurtbox.area_entered.connect(self.on_hit_taken)
	
	if player:
		player.closest_nav_point_changed.connect(self.on_player_moved)
	
	behavior_tree.blackboard.set_value("dir_to_target", Vector3.ZERO)


func _physics_process(delta):
	if is_dead:
		return
	
	if dashing:
		velocity_component.fixed_movement(dash_vector * delta)
	else:
		movement_process(delta)
	
	if detection_range > distance_to_player:
		look_at_player()
	
	velocity_component.move(delta)


func tick():
	if is_dead:
		return
	
	space_state = get_world_3d().direct_space_state
	distance_to_player = global_position.distance_to(player.global_position)
	behavior_tree.tick()


func explode():
	explosion_radius.disabled = false
	call_deferred("death")

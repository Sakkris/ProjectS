extends CharacterBody3D
class_name EnemyDrone

@export var attack_range = 10
@export var detection_range = 15

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var animation_player: AnimationPlayer = $DroneMesh/AnimationPlayer
@onready var behavior_tree: BeehaveTree = $BeehaveTree
@onready var hurt_box_collision: CollisionShape3D = $Hurtbox/CollisionShape3D
@onready var collision: CollisionShape3D = $CollisionShape3D

# Used for raycasts
var space_state = null

# Player References
var player: Player = null
var distance_to_player: float = 0.0

# Movement Variables
var target_point: Vector3 = Vector3.ZERO
var current_target_index: int = -1
var path_to_follow: PackedVector3Array
var update_path_queued: bool = false


func _ready():
	$Hurtbox.area_entered.connect(self.on_hit_taken)
	
	if player:
		player.closest_nav_point_changed.connect(on_player_moved)
	
#	$DroneMesh/bad_Ship/main_body.visibility_range_begin = 0
#	$DroneMesh/bad_Ship/main_body.visibility_range_end = 10
#	$MeshInstance3D.visibility_range_begin = 10


func tick():
	pass


func movement_process(delta):
	if target_point != Vector3.ZERO:
		var dir_to_target = global_transform.origin.direction_to(target_point).normalized()
		
		velocity_component.accelerate_in_direction(dir_to_target, delta)
		
		if global_transform.origin.distance_to(target_point) < 2.0:
			next_target_point()
			velocity_component.turn_target_point(target_point)
	else:
		velocity_component.decelerate(delta)


func next_target_point():
	if path_to_follow.size() > current_target_index + 1:
		current_target_index += 1
		target_point = path_to_follow[current_target_index]
	else:
		target_point = Vector3.ZERO


func get_distance_to_player() -> float:
	return global_transform.origin.distance_to(player.global_transform.origin)


func full_stop():
	velocity_component.full_stop()


func look_at_player():
	var direction_to_player = global_position.direction_to(player.global_position)
	var looking_point = player.global_position
	looking_point.y += player.height / 2.0
	
#	var up_direction = direction_to_player.rotated()
	if direction_to_player == Vector3.UP || direction_to_player == Vector3.DOWN:
		look_at(looking_point, Vector3.FORWARD)
	else:
		look_at(looking_point)
	
#	rotate_object_local(global_transform.basis.y.normalized(), PI)


func play_animation(animation_name):
	if animation_player:
		if animation_player.has_animation(animation_name):
			animation_player.play(animation_name)


func play_inverse_animation(animation_name, next_animation):
	if animation_player:
		if animation_player.has_animation(animation_name):
			animation_player.play_backwards(animation_name)
		
		if animation_player.has_animation(next_animation):
			animation_player.queue(next_animation)


func is_animation_playing(animation_name):
	if animation_player:
		if animation_player.current_animation == animation_name:
			return animation_player.is_playing()
	
	return false


func is_current_animation(animation_name):
	if animation_player:
		return animation_player.current_animation == animation_name
	
	return false


func queue_update_path():
	update_path_queued = true


func death():
	GameEvents.emit_enemy_died(self)
	target_point = Vector3.ZERO
	
	hurt_box_collision.disabled = true
	collision.disabled = true
	
	if $MeshInstance3D.visible:
		$MeshInstance3D.visible = false
		queue_free()
	else:
		$DroneMesh/bad_Ship/main_body.visible = false
		$DroneMesh/bad_Ship/explosion_pieces.visible = true
		animation_player.play("explode")
		await animation_player.animation_finished
		queue_free()


func on_hit_taken(_area):
	call_deferred("death")


func on_player_moved():
	queue_update_path()

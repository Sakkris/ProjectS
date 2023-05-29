extends CharacterBody3D

@export var attack_range = 10
@export var detection_range = 15
@export var dash_speed = 20

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var animation_player: AnimationPlayer = $DroneMesh/AnimationPlayer
@onready var behavior_tree: BeehaveTree = $BeehaveTree
@onready var hurt_box_collision: CollisionShape3D = $Hurtbox/CollisionShape3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var player: Player = null
var distance_to_player: float = 0.0
var path_to_follow: PackedVector3Array
var target_point: Vector3 = Vector3.ZERO

var space_state = null

var dashing = false
var dashing_target = Vector3.ZERO
var current_target_index: int = -1
var update_path_queued: bool = false


func _ready():
	$Hurtbox.area_entered.connect(self.on_hit_taken)
	
	if player:
		player.closest_nav_point_changed.connect(on_player_moved)
	
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
	pass


func dash_check(delta) -> bool:
	if dashing && dashing_target != Vector3.ZERO:
		var dir_to_target = global_transform.origin.direction_to(dashing_target).normalized()
		velocity_component.fixed_movement(dir_to_target * dash_speed * delta)
		
		return true
	
	return false


func movement_process(delta):
	if target_point != Vector3.ZERO:
		var dir_to_target = global_transform.origin.direction_to(target_point).normalized()
		
		velocity_component.accelerate_in_direction(dir_to_target, delta)
		
		if global_transform.origin.distance_to(target_point) < 2.0:
			next_target_point()
			velocity_component.change_direction(global_transform.origin.direction_to(target_point).normalized())
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
	if direction_to_player == Vector3.UP || direction_to_player == Vector3.DOWN:
		look_at(player.global_position, Vector3.FORWARD)
	else:
		look_at(player.global_position)
	
	rotate_object_local(global_transform.basis.y.normalized(), PI)


func play_animation(animation_name):
	if animation_player:
		if animation_player.has_animation(animation_name):
			animation_player.play(animation_name)


func is_animation_playing(animation_name):
	if animation_player:
		if animation_player.current_animation == animation_name:
			return animation_player.is_playing()
	
	return false


func is_current_animation(animation_name):
	if animation_player:
		return animation_player.current_animation == animation_name
	
	return false


func dash_attack(target: Vector3):
	dashing = true
	dashing_target = target
	
	var dir_to_target = global_position.direction_to(dashing_target).normalized()
	velocity = dir_to_target * dash_speed / 2.0


func end_dash():
	dashing = false
	dashing_target = Vector3.ZERO
	animation_player.play_backwards("engage_transition")
	animation_player.queue("idle")
	velocity_component.velocity = velocity


func queue_update_path():
	update_path_queued = true


func death():
	hurt_box_collision.disabled = true
	collision.disabled = true
	
	if $MeshInstance3D.visible:
		$MeshInstance3D.visible = false
		queue_free()
	
	$DroneMesh/bad_Ship/main_body.visible = false
	$DroneMesh/bad_Ship/explosion_pieces.visible = true
	animation_player.play("explode")
	await animation_player.animation_finished
	queue_free()


func on_hit_taken(_area):
	GameEvents.emit_enemy_died(self)
	
	call_deferred("death")


func on_player_moved():
	queue_update_path()

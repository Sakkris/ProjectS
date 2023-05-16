extends CharacterBody3D

@export var attack_range = 10
@export var dash_speed = 20

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var animation_player: AnimationPlayer = $DroneMesh/AnimationPlayer
@onready var detection_range: Area3D = $DetectionRange
@onready var behavior_tree: BeehaveTree = $BeehaveTree

var player: Player = null
var path_to_follow: PackedVector3Array
var target_point: Vector3 = Vector3.INF

var space_state

var dashing = false
var dashing_target = Vector3.INF
var current_target_index: int = 0


func _ready():
	$Hurtbox.area_entered.connect(self.on_hit_taken)


func _physics_process(delta):
	space_state = get_world_3d().direct_space_state
	
	if !dash_check(delta):
		movement_process(delta)
		
		if detection_range.has_overlapping_bodies():
			look_at_player()
	
	velocity_component.move(delta)


func tick():
	behavior_tree.tick()


func dash_check(delta) -> bool:
	if dashing && dashing_target != Vector3.INF:
		var dir_to_target = global_transform.origin.direction_to(dashing_target).normalized()
		velocity_component.fixed_movement(dir_to_target * dash_speed * delta)
		
		return true
	
	return false


func movement_process(delta):
	if target_point != Vector3.INF:
		var dir_to_target = global_transform.origin.direction_to(target_point).normalized()
		
		velocity_component.accelerate_in_direction(dir_to_target, delta)
		
		if global_transform.origin.distance_to(target_point) < 0.5:
			next_target_point()
			velocity_component.change_direction(global_transform.origin.direction_to(target_point).normalized())
			
	else:
		velocity_component.decelerate(delta)


func next_target_point():
	if path_to_follow.size() > current_target_index + 1:
		current_target_index += 1
		target_point = path_to_follow[current_target_index]
	else:
		target_point = Vector3.INF


func get_distance_to_player() -> float:
	return global_transform.origin.distance_to(player.global_transform.origin)


func full_stop():
	velocity_component.full_stop()


func look_at_player():
	look_at(player.global_transform.origin)
	rotate_object_local(global_transform.basis.y.normalized(), PI)


func play_animation(animation_name):
	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name)


func is_animation_playing(animation_name):
	if animation_player.current_animation == animation_name:
		return animation_player.is_playing()
	else: 
		return false


func is_current_animation(animation_name):
	return animation_player.current_animation == animation_name


func dash_attack(target: Vector3):
	dashing = true
	dashing_target = target
	
	var dir_to_target = global_transform.origin.direction_to(dashing_target).normalized()
	velocity = dir_to_target * dash_speed / 2.0


func end_dash():
	dashing = false
	dashing_target = Vector3.INF
	animation_player.play_backwards("engage_transition")
	animation_player.queue("idle")
	velocity_component.velocity = velocity

func on_hit_taken(_area):
	GameEvents.emit_enemy_died(self)
	queue_free()


func test_func():
	pass

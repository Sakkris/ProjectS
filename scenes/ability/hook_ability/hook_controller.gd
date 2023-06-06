extends Ability

@export var throw_hook_audio: AudioStreamPlayer3D
@export var retract_hook_audio: AudioStreamPlayer3D

@onready var hook_scene: PackedScene = preload("res://scenes/game_object/projectile/player_hook/hook.tscn")

var hook_instance
var in_use: bool = false
var locked: bool = false
var locked_up: Vector3 = Vector3.ZERO


func _physics_process(delta):
	if in_use && gun_nuzzle != null:
		hook_instance.origin = gun_nuzzle 
		hook_instance.update(delta)
		
		if hook_instance.current_state == hook_instance.states.COLLIDING:
			if locked:
				rotate_around_point(delta)
			else: 
				if retract_hook_audio and !retract_hook_audio.playing:
					retract_hook_audio.play()
				
				go_to_collision_point(delta)


func use():
	if gun_nuzzle == null:
		return
	
	if throw_hook_audio:
		throw_hook_audio.play()
	
	hook_instance = hook_scene.instantiate()
	hook_instance.origin = gun_nuzzle 
	hook_instance.global_transform = gun_nuzzle.global_transform
	hook_instance.change_state(hook_instance.states.HOOKING)
	
	get_tree().get_first_node_in_group("projectile_manager").add_child(hook_instance)
	
	in_use = true
	await hook_instance.finished_retracting
	
	if throw_hook_audio:
		throw_hook_audio.play()
	
	if retract_hook_audio and retract_hook_audio.playing:
		retract_hook_audio.stop()
	
	in_use = false


func stop():
	hook_instance.change_state(hook_instance.states.RETRACTING)


func reset():
	hook_instance.emit_finished_retracting()
	hook_instance.queue_free()


func use_modifier(modifier: String):
	match modifier:
		"Lock":
			locked = true


func stop_modifier(modifier: String):
	match modifier:
		"Lock":
			locked_up = Vector3.ZERO
			locked = false


func rotate_around_point(_delta):
	var direction = gun_nuzzle.global_position.direction_to(hook_instance.hook_tip.global_position)
	
	if locked_up == Vector3.ZERO:
		var direction_basis = Basis.looking_at(hook_instance.hook_tip.global_position, velocity_component.velocity)
		locked_up = direction_basis.x
	
	direction = direction.rotated(locked_up, PI/2)
	
	if direction.normalized().dot(velocity_component.velocity.normalized()) < 0:
		direction = -direction
	
	velocity_component.change_direction(direction)


func go_to_collision_point(delta):
	var direction = gun_nuzzle.global_position.direction_to(hook_instance.hook_tip.global_position)
	
	velocity_component.accelerate_in_direction(direction * hook_instance.current_acceleration, delta)

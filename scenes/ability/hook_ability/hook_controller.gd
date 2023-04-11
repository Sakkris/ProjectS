extends Ability

@onready var hook_scene: PackedScene = preload("res://scenes/game_object/projectile/player_hook/hook.tscn")

var hook_instance
var in_use: bool = false


func _physics_process(delta):
	if in_use && gun_nuzzle != null:
		hook_instance.origin = gun_nuzzle 
		hook_instance.update(delta)
		
		if hook_instance.current_state == hook_instance.states.COLLIDING:
			go_to_collision_point(delta)


func use():
	if gun_nuzzle == null:
		return
	
	hook_instance = hook_scene.instantiate()
	hook_instance.origin = gun_nuzzle 
	hook_instance.global_transform = gun_nuzzle.global_transform
	hook_instance.change_state(hook_instance.states.HOOKING)
	
	get_tree().get_first_node_in_group("projectile_manager").add_child(hook_instance)
	
	in_use = true
	await hook_instance.finished_retracting
	in_use = false


func stop():
	hook_instance.change_state(hook_instance.states.RETRACTING)


func reset():
	hook_instance.emit_finished_retracting()
	hook_instance.queue_free()


func go_to_collision_point(delta):
	var direction = gun_nuzzle.global_position.direction_to(hook_instance.hook_tip.global_position)
	
	velocity_component.accelerate_in_direction(direction * hook_instance.HOOK_PULL_SPEED, delta)

extends ActionLeaf

@export var bullet_scene: PackedScene

@onready var projectile_manager = get_tree().get_first_node_in_group("projectile_manager")
@onready var shooting_cooldown_timer = $CooldownTimer

var shooting_animation = "engage_shoot"


func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.attack_range_limit < actor.distance_to_player:
		return FAILURE
	
	actor.look_at_player()
	
	if shooting_cooldown_timer.is_stopped():
		var bullet = bullet_scene.instantiate()
		
		projectile_manager.add_child(bullet)
		bullet.global_transform = actor.gun_nuzzle.global_transform
		
		actor.play_animation(shooting_animation)
		
		shooting_cooldown_timer.start()
	
	return RUNNING

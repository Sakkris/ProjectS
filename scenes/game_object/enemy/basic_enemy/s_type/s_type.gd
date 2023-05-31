extends EnemyDrone


func _ready():
	$Hurtbox.area_entered.connect(on_hit_taken)
	
	if player:
		player.closest_nav_point_changed.connect(on_player_moved)


func _physics_process(delta):
	movement_process(delta)
	
	if detection_range > distance_to_player:
		look_at_player()
	
	velocity_component.move(delta)


func tick():
	space_state = get_world_3d().direct_space_state
	distance_to_player = global_position.distance_to(player.global_position)
	behavior_tree.tick()

extends EnemyDrone


func _ready():
	$Hurtbox.area_entered.connect(self.on_hit_taken)


func _physics_process(delta):
	movement_process(delta)
	
	if detection_range > distance_to_player:
		look_at_player()
	
	velocity_component.move(delta)


func tick():
	space_state = get_world_3d().direct_space_state
	distance_to_player = global_position.distance_to(player.global_position)
	behavior_tree.tick()

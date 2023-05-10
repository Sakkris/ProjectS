class_name GetInRange extends ActionLeaf

@onready var path_cooldown_timer = $Timer


func tick(actor: Node, blackboard: Blackboard) -> int:
	# Verificar se está em Range do PLayer
		# Verificar se há colisões entre o Drone e o Player (Caso não -> SUCCESS)
	# Obter path a partir do AStar (null -> FAILURE)
	# Seguir Path (-> RUNNING)
	
	if !NavPointGenerator.generated:
		return FAILURE
	
	var current_location = actor.global_position
	var player_location = owner.player.global_position
	var is_player_far = current_location.distance_squared_to(player_location) >= 30 ** 2
	
	if !path_cooldown_timer.is_stopped() && is_player_far:
		return SUCCESS
	
	var path = NavPointGenerator.generate_path(current_location, player_location)
	
	if is_player_far:
		path_cooldown_timer.start()
	
	return SUCCESS

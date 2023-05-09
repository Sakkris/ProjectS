class_name GetInRange extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	# Verificar se está em Range do PLayer
		# Verificar se há colisões entre o Drone e o Player (Caso não -> SUCCESS)
	# Obter path a partir do AStar (null -> FAILURE)
	# Seguir Path (-> RUNNING)
	
	var current_location = actor.global_position
	var player_location = owner.player.global_position
	var path = NavPointGenerator.generate_path(current_location, player_location)
	
	
	return SUCCESS

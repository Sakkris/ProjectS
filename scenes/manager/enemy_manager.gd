extends Node

@export var player: Player

@onready var timer: Timer = $Timer
@onready var process_balancer: ProcessBalancer = $ProcessBalancer


var enemy = preload("res://scenes/game_object/enemy/basic_enemy/e_type/e_type.tscn")
var spawn_areas: Array[Node]
var enemy_limit
var number_of_enemies = 0


func _ready():
	timer.timeout.connect(func(): spawn_enemy())
	GameEvents.game_start.connect(func(): timer.start())
	GameEvents.enemy_died.connect(on_enemy_destroyed) 
#	GameEvents.game_start.connect(func(): spawn_enemy())
#	GameEvents.enemy_died.connect(func(): spawn_enemy())
	GameEvents.game_start.connect(func(): spawn_objective())
	GameEvents.objective_destroyed.connect(func(): spawn_objective())
	
	for child in get_children():
		if child is SpawnArea:
			spawn_areas.append(child)
	
	process_balancer.set_limits(GameProperties.max_enemies / GameProperties.max_enemies_per_frame, GameProperties.max_enemies_per_frame)
	enemy_limit = GameProperties.max_enemies


func spawn_enemy():
	if number_of_enemies >= enemy_limit:
		return
	
	if spawn_areas.is_empty():
		return
	
	var selected_area = select_random_area()
	if selected_area == null:
		return
	
	var positionInArea = get_rand_position(selected_area)
	
	var enemy_instance = enemy.instantiate()
	enemy_instance.position = positionInArea
	enemy_instance.player = player
	add_child(enemy_instance)
	
	GameEvents.emit_enemy_spawned(enemy_instance)
	number_of_enemies += 1
	
	process_balancer.add_to_queue(enemy_instance, Callable(enemy_instance, "tick"))
	
	update_timer()


func update_timer():
	var tmp_time = timer.wait_time
	
	tmp_time *= .05
	timer.wait_time = max(timer.wait_time - tmp_time, 1)
	timer.start()


func select_random_area():
	var selected_area: SpawnArea
	var number_of_tries = 0
	
	selected_area = spawn_areas.pick_random()
	
	while selected_area.has_overlapping_areas() || selected_area.has_overlapping_bodies():
		if number_of_tries >= 10:
			return null
		
		selected_area = spawn_areas.pick_random()
		number_of_tries += 1
	
	return selected_area


func get_rand_position(area):
	var collision_shape = area.get_child(0)
	var center_position = collision_shape.position + area.position
	var area_size = collision_shape.shape.extents
	
	var positionInArea = Vector3.ZERO
	positionInArea.x = (randi() % int(area_size.x)) - (area_size.x/2) + center_position.x
	positionInArea.y = (randi() % int(area_size.y)) - (area_size.y/2) + center_position.y
	positionInArea.z = (randi() % int(area_size.z)) - (area_size.z/2) + center_position.z
	
	return positionInArea


func on_enemy_destroyed(enemy_instance):
	process_balancer.remove_from_queue(enemy_instance)
	number_of_enemies -= 1


func spawn_objective():
	var selected_area = select_random_area()
	if selected_area == null:
		return
	
	var positionInArea = get_rand_position(selected_area)

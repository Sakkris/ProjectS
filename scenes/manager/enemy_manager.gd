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
#	GameEvents.game_start.connect(func(): spawn_enemy())
	GameEvents.enemy_died.connect(on_enemy_destroyed)
#	GameEvents.enemy_died.connect(func(): spawn_enemy())
	
	spawn_areas = get_children()
	spawn_areas.pop_front()
	spawn_areas.pop_front()
	
	enemy_limit = process_balancer.number_of_rows * process_balancer.row_item_limit


func spawn_enemy():
	if number_of_enemies >= enemy_limit:
		return
	
	if spawn_areas.is_empty():
		return
	
	var selected_area = spawn_areas.pick_random()
	
	if selected_area.get_child_count() == 0:
		return
		
	var positionInArea = get_rand_position(selected_area)
	
	var enemy_instance = enemy.instantiate()
	enemy_instance.position = positionInArea
	enemy_instance.player = player
	add_child(enemy_instance)
	
	GameEvents.emit_enemy_spawned(enemy_instance)
	number_of_enemies += 1
	
	process_balancer.add_to_queue(enemy_instance, Callable(enemy_instance, "tick"))
	
	var tmp_time = timer.wait_time
	
	tmp_time *= .1
	timer.wait_time = max(timer.wait_time - tmp_time, 3)
	timer.start()


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

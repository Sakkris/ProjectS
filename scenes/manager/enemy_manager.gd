extends Node

@export var player: Player

@onready var timer = $Timer

var enemy = preload("res://scenes/game_object/enemy/basic_enemy/e_type/e_type.tscn")
var spawn_areas: Array[Node]
var enemy_limit = 5
var number_of_enemies = 0


func _ready():
	timer.timeout.connect(func(): spawn_enemy())
	GameEvents.game_start.connect(func(): timer.start())
	GameEvents.enemy_died.connect(func(): number_of_enemies -= 1)
	#GameEvents.enemy_died.connect(func(): spawn_enemy())
	
	spawn_areas = get_children()
	spawn_areas.pop_front()


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


func get_rand_position(area):
	var collision_shape = area.get_child(0)
	var center_position = collision_shape.position + area.position
	var area_size = collision_shape.shape.extents
	
	var positionInArea = Vector3.ZERO
	positionInArea.x = (randi() % int(area_size.x)) - (area_size.x/2) + center_position.x
	positionInArea.y = (randi() % int(area_size.y)) - (area_size.y/2) + center_position.y
	positionInArea.z = (randi() % int(area_size.z)) - (area_size.z/2) + center_position.z
	
	return positionInArea


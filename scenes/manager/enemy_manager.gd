extends Node

@export var spawn_areas: Array[Node]

@onready var timer = $Timer

var enemy = preload("res://scenes/game_object/enemy/basic_enemy/enemy_drone.tscn")


func _ready():
#	timer.timeout.connect(func(): spawn_enemy())
	GameEvents.enemy_died.connect(func(): spawn_enemy())
	
	spawn_areas = get_children()
	spawn_areas.pop_front()
	spawn_enemy()


func spawn_enemy():
	if spawn_areas.is_empty():
		return
	
	var selected_area = spawn_areas.pick_random()
	
	if selected_area.get_child_count() == 0:
		return
		
	var positionInArea = get_rand_position(selected_area)
	
	var enemy_instance = enemy.instantiate()
	enemy_instance.position = positionInArea
	add_child(enemy_instance)
	
	GameEvents.emit_enemy_spawned(enemy_instance)


func get_rand_position(area):
	var collision_shape = area.get_child(0)
	var center_position = collision_shape.position + area.position
	var area_size = collision_shape.shape.extents
	
	var positionInArea = Vector3.ZERO
	positionInArea.x = (randi() % int(area_size.x)) - (area_size.x/2) + center_position.x
	positionInArea.y = (randi() % int(area_size.y)) - (area_size.y/2) + center_position.y
	positionInArea.z = (randi() % int(area_size.z)) - (area_size.z/2) + center_position.z
	
	return positionInArea

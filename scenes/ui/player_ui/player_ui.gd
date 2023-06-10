extends Node3D

@export var MAX_SCALE: float = 0.1
@export var MIN_SCALE: float = 0.01
@export var MAX_DISTANCE_SQUARED: float = 1600
@export var MIN_DISTANCE_SQUARED: float = 25

@onready var enemy_icon_scene = preload("res://scenes/ui/misc/enemy_icon.tscn")

@onready var time_label = $SubViewport/PlayerUIControl/MarginContainer/TimeLabel
@onready var kill_label = $SubViewport/PlayerUIControl/KillMarginContainer/KillLabel
@onready var player_speed_label = $SubViewport/PlayerUIControl/SpeedMarginContainer/SpeedLabel
@onready var fps_counter = $SubViewport/PlayerUIControl/FPSMarginContainer/FPSCounter

@onready var viewport = $SubViewport
@onready var collision_shape = $CollisionShape3D

var num_kills = 0
var player
var enemy_icons = {}


func _ready():
	GameEvents.game_time_updated.connect(on_game_time_updated)
	GameEvents.enemy_died.connect(on_enemy_destroyed)
	
	viewport.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
	viewport.transparent_bg = true
	
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()
	$ViewportQuad.material_override.flags_transparent = true
	
	await owner.ready
	player = owner


func _process(_delta):
	fps_counter.set_text(str(Performance.get_monitor(Performance.TIME_FPS)) + " fps") 	
	
	player_speed_label.set_text("%.0f" % player.velocity.length())


func update_kill_label():
	num_kills += 1
	kill_label.set_text("%02d" % num_kills)


func draw_enemy_icon_at_position(global_icon_position, enemy_id, distance_squared):
	if !enemy_icons.has(enemy_id):
		var enemy_icon_instance = enemy_icon_scene.instantiate()
		viewport.add_child(enemy_icon_instance)
		enemy_icons[enemy_id] = enemy_icon_instance
	
	var new_scale = get_icon_scale(distance_squared)
	enemy_icons[enemy_id].scale = Vector2(new_scale, new_scale)
	
	enemy_icons[enemy_id].position = point_to_viewport_position(global_icon_position)
#	print(point_to_viewport_position(global_icon_position))


func get_icon_scale(distance_squared):
	var scale_factor = inverse_lerp(MIN_DISTANCE_SQUARED, MAX_DISTANCE_SQUARED, distance_squared)
	scale_factor = clamp(scale_factor, 0.0, 1.0)
	scale_factor = 1 - scale_factor
	
	return lerp(MIN_SCALE, MAX_SCALE, scale_factor)


func remove_enemy_icon(enemy_id):
	if enemy_icons.has(enemy_id):
		enemy_icons[enemy_id].queue_free()
		enemy_icons.erase(enemy_id)


func point_to_viewport_position(point_global_position: Vector3) -> Vector2: 
	var local_colision_point = to_local(point_global_position);
	var viewport_point = Vector2(local_colision_point.x, -local_colision_point.y)
	
	viewport_point = viewport_point + Vector2(0.5, 0.5)
	viewport_point.x *= viewport.size.x
	viewport_point.y *= viewport.size.y
	
	#print(viewport_point)
	
	return viewport_point


func change_indicator_icon(side):
	match side:
		1:
			$SubViewport/PlayerUIControl/LeftIconContainer/BulletIcon.visible = not $SubViewport/PlayerUIControl/LeftIconContainer/BulletIcon.visible
			$SubViewport/PlayerUIControl/LeftIconContainer/HandIcon.visible = not $SubViewport/PlayerUIControl/LeftIconContainer/HandIcon.visible
		2:
			$SubViewport/PlayerUIControl/RightIconContainer/BulletIcon.visible = not $SubViewport/PlayerUIControl/RightIconContainer/BulletIcon.visible
			$SubViewport/PlayerUIControl/RightIconContainer/HandIcon.visible = not $SubViewport/PlayerUIControl/RightIconContainer/HandIcon.visible


func on_game_time_updated(time_elapsed):
	var minute: int = time_elapsed / 60
	var second: int = time_elapsed - minute * 60
	
	time_label.set_text("%02d:%02d" % [minute, second])
#	print("%02d:%02d" % [minute, second])


func on_enemy_destroyed(_enemy):
	update_kill_label()


extends Node3D

@onready var lockon_crosshiar_scene = preload("res://scenes/ui/misc/lockon_crosshair.tscn")

@onready var time_label = $SubViewport/PlayerUIControl/TimeLabel
@onready var kill_label = $SubViewport/PlayerUIControl/KillMarginContainer/HBoxContainer/KillLabel
@onready var player_speed_label = $SubViewport/PlayerUIControl/SpeedMarginContainer/SpeedLabel
@onready var fps_counter = $SubViewport/PlayerUIControl/FPSMarginContainer/FPSCounter

@onready var viewport = $SubViewport
@onready var collision_shape = $CollisionShape3D

var num_kills = 0
var player
var lockon_crosshairs = {}

func _ready():
	GameEvents.game_time_updated.connect(on_game_time_updated)
	GameEvents.enemy_died.connect(func(): update_kill_label())
	
	var viewport: SubViewport = $SubViewport
	viewport.set_clear_mode(SubViewport.CLEAR_MODE_ALWAYS)
	viewport.transparent_bg = true
	
	$ViewportQuad.material_override.albedo_texture = viewport.get_texture()
	$ViewportQuad.material_override.flags_transparent = true
	
	await owner.ready
	player = owner


func _process(_delta):
	fps_counter.set_text(str(Engine.get_frames_per_second()) + " fps")
	
	player_speed_label.set_text("%.2f m/s" % player.velocity.length())


func update_kill_label():
	num_kills += 1
	kill_label.set_text("%02d" % num_kills)


func draw_crosshair_at_position(global_position: Vector3, crosshair_id: int):
	if not lockon_crosshairs.has(crosshair_id):
		var crosshair_instance: Node2D = lockon_crosshiar_scene.instantiate()
		viewport.add_child(crosshair_instance)
		lockon_crosshairs[crosshair_id] = crosshair_instance
	
	print(viewport.size, " | ", point_to_viewport_position(global_position), " | ", lockon_crosshairs[crosshair_id].position)
	
	lockon_crosshairs[crosshair_id].position = point_to_viewport_position(global_position)


func remove_crosshair(crosshair_id: int):
	if lockon_crosshairs.has(crosshair_id):
		lockon_crosshairs[crosshair_id].queue_free()
		lockon_crosshairs.erase(crosshair_id)


func point_to_viewport_position(global_position: Vector3) -> Vector2: 
	var local_colision_point = collision_shape.to_local(global_position);
	var viewport_point = Vector2(local_colision_point.x, -local_colision_point.y)
	
	viewport_point = viewport_point + Vector2(0.5, 0.5)
	viewport_point.x *= viewport.size.x
	viewport_point.y *= viewport.size.y
	
	return viewport_point


func on_game_time_updated(time_elapsed):
	var minute: int = time_elapsed / 60
	var second: int = time_elapsed - minute * 60
	
	time_label.set_text("%02d:%02d" % [minute, second])
#	print("%02d:%02d" % [minute, second])



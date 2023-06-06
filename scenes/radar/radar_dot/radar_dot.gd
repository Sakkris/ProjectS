extends Node

@onready var lockon_crosshair_scene = preload("res://scenes/ui/misc/lockon_crosshair.tscn")
@onready var lock_on_audio: AudioStreamPlayer = $LockOnAudio

var id
var enemy = null
var crosshair = null
var radar_ref = null


func tick():
	if enemy == null || radar_ref == null:
		return
	
	if is_player_looking_at_enemy(enemy):
		radar_ref.player_ui.remove_enemy_icon(id)
		
		if crosshair == null:
			instanciate_crosshair(enemy)
		
		return
	
	if crosshair != null:
		crosshair.queue_free()
		crosshair = null
	
	var icon_position = get_enemy_icon_position()
	
	if icon_position == null:
		return
	
	var distance_squared = radar_ref.global_position.distance_squared_to(enemy.global_position)
	
	radar_ref.player_ui.draw_enemy_icon_at_position(icon_position, id, distance_squared)


func is_player_looking_at_enemy(enemy_ref: CharacterBody3D) -> bool:
	var player_camera_foward = -(radar_ref.player_camera.global_transform.basis.z)
	var direction_to_enemy = radar_ref.player_camera.global_transform.origin.direction_to(enemy_ref.global_transform.origin)
	
	return player_camera_foward.dot(direction_to_enemy) > .85


func instanciate_crosshair(enemy_ref: CharacterBody3D):
	lock_on_audio.play()
	crosshair = lockon_crosshair_scene.instantiate()
	enemy_ref.add_child(crosshair)
	crosshair.global_transform = enemy_ref.global_transform


func get_enemy_icon_position():
	var projected_enemy_position = radar_ref.foward_plane.project(enemy.global_transform.origin)
	
	var query = PhysicsRayQueryParameters3D.create(projected_enemy_position, radar_ref.player_ui.global_transform.origin)
	query.collision_mask = 1 << 5
	query.hit_from_inside = true
	query.hit_back_faces = true
	var result = radar_ref.space_state.intersect_ray(query)
	
	if !result.is_empty():
		return result.position
	
	return null

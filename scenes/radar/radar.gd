extends Node3D

@onready var detection_area: Area3D = $DetectionArea 
@onready var player_ui: StaticBody3D = $"../XROrigin3D/XRCamera3D/PlayerUI"
@onready var player_camera: XRCamera3D = $"../XROrigin3D/XRCamera3D"

@onready var lockon_crosshiar_scene = preload("res://scenes/ui/misc/lockon_crosshair.tscn")

var enemies_detected = {}
var enemies_locked_on = {}
var next_available_id = 0
var space_state = null


func _ready():
	detection_area.body_entered.connect(on_detection_area_entered)
	detection_area.body_exited.connect(on_detection_area_exited)


func _physics_process(delta):
	space_state = get_world_3d().direct_space_state
	
	for enemy in enemies_detected:
		if is_player_looking_at_enemy(enemies_detected[enemy], enemy):
			if !enemies_locked_on.has(enemy):
				enemies_locked_on[enemy] = enemies_detected[enemy]
		else:
			if enemies_locked_on.has(enemy):
				player_ui.remove_crosshair(enemy)
				enemies_locked_on.erase(enemy)


func enemy_detected(detected_enemy):
	enemies_detected[next_available_id] = detected_enemy
	
	for enemy in enemies_detected:
		next_available_id += 1
		if not enemies_detected.has(next_available_id):
			break


func enemy_gone(gone_enemy):
	for enemy in enemies_detected:
		if enemies_detected[enemy] == gone_enemy:
			enemies_detected.erase(enemy)
			
			if enemies_locked_on.has(enemy):
				player_ui.remove_crosshair(enemy)
				enemies_locked_on.erase(enemy)
			
			next_available_id = enemy
			break


func is_player_looking_at_enemy(enemy: CharacterBody3D, enemy_id) -> bool:
	var player_camera_foward = -player_camera.global_transform.basis.z
	if player_camera_foward.dot(enemy.global_position.normalized()) < .5:
		return false
	
	var query = PhysicsRayQueryParameters3D.create(player_camera.global_position, enemy.global_position)
	query.collision_mask = 0x0020
	var result = space_state.intersect_ray(query)
	
	if result:
		if !enemies_locked_on.has(enemy_id):
			#player_ui.draw_crosshair_at_position(result.position, enemy_id)
			instanciate_crosshair(enemy, enemy_id)
			print("Instanciating")
		return true
	
	return false


func instanciate_crosshair(enemy: CharacterBody3D, enemy_id):
	var crosshair_instance = lockon_crosshiar_scene.instantiate()
	enemy.add_child(crosshair_instance)
	crosshair_instance.global_transform = enemy.global_transform
#	crosshair_instance.cam = player_camera
#	crosshair_instance.enemy = enemy


func on_detection_area_entered(other_object):
	enemy_detected(other_object)


func on_detection_area_exited(other_objet):
	enemy_gone(other_objet)

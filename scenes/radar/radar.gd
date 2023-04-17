extends Node3D

@onready var detection_area: Area3D = $DetectionArea 
@onready var player_ui: StaticBody3D = $"../XROrigin3D/XRCamera3D/PlayerUI"
@onready var player_camera: XRCamera3D = $"../XROrigin3D/XRCamera3D"

@onready var lockon_crosshiar_scene = preload("res://scenes/ui/misc/lockon_crosshair.tscn")

var enemies_detected = {}
var instanciated_crosshairs = {}
var next_available_id = 0
var space_state = null


func _ready():
	detection_area.body_entered.connect(on_detection_area_entered)
	detection_area.body_exited.connect(on_detection_area_exited)


func _physics_process(delta):
	space_state = get_world_3d().direct_space_state
	
	for enemy in enemies_detected:
		if is_player_looking_at_enemy(enemies_detected[enemy], enemy):
			if (!instanciated_crosshairs.has(enemy)):
				instanciate_crosshair(enemies_detected[enemy], enemy)
		else:
			if instanciated_crosshairs.has(enemy):
				instanciated_crosshairs[enemy].queue_free()
				instanciated_crosshairs.erase(enemy)


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
			
			if instanciated_crosshairs.has(enemy):
				instanciated_crosshairs[enemy].queue_free()
				instanciated_crosshairs.erase(enemy)
			
			next_available_id = enemy
			break


func is_player_looking_at_enemy(enemy: CharacterBody3D, enemy_id) -> bool:
	var player_camera_foward = -player_camera.global_transform.basis.z
	var direction_to_enemy = player_camera.global_transform.origin.direction_to(enemy.global_transform.origin)
	
	return player_camera_foward.dot(direction_to_enemy) > .85


func instanciate_crosshair(enemy: CharacterBody3D, enemy_id):
	var crosshair_instance = lockon_crosshiar_scene.instantiate()
	enemy.add_child(crosshair_instance)
	crosshair_instance.global_transform = enemy.global_transform
	
	instanciated_crosshairs[enemy_id] = crosshair_instance


func on_detection_area_entered(other_object):
	enemy_detected(other_object)


func on_detection_area_exited(other_objet):
	enemy_gone(other_objet)

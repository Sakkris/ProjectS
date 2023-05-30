extends Node3D


@export var radar_dot_scene: PackedScene

@onready var detection_area: Area3D = $DetectionArea 
@onready var player_ui: StaticBody3D = $"../XROrigin3D/XRCamera3D/PlayerUI"
@onready var player_camera: XRCamera3D = $"../XROrigin3D/XRCamera3D"
@onready var load_balancer: ProcessBalancer = $ProcessBalancer

var enemies_detected = {}
var instanciated_crosshairs = {}
var next_available_id = 0
var space_state = null
var foward_plane: Plane
var current_frame = 0


func _ready():
	detection_area.body_entered.connect(on_detection_area_entered)
	detection_area.body_exited.connect(on_detection_area_exited)


func _physics_process(_delta):
	foward_plane = Plane(player_camera.global_transform.basis.z, player_ui.global_transform.origin)
	space_state = get_world_3d().direct_space_state


func enemy_detected(detected_enemy):
	var radar_dot_instance = radar_dot_scene.instantiate()
	radar_dot_instance.id = next_available_id
	radar_dot_instance.enemy = detected_enemy
	radar_dot_instance.radar_ref = self
	add_child(radar_dot_instance)
	
	enemies_detected[next_available_id] = radar_dot_instance
	load_balancer.add_to_queue(detected_enemy, Callable(radar_dot_instance, "tick"))
	
	update_next_id()


func update_next_id():
	for enemy in enemies_detected:
		next_available_id += 1
		if not enemies_detected.has(next_available_id):
			break


func enemy_gone(gone_enemy):
	for enemy in enemies_detected:
		if enemies_detected[enemy].enemy == gone_enemy:
			if instanciated_crosshairs.has(enemy):
				instanciated_crosshairs[enemy].queue_free()
				instanciated_crosshairs.erase(enemy)
			
			player_ui.remove_enemy_icon(enemy)
			enemies_detected.erase(enemy)
			update_next_id()
			break
	
	load_balancer.remove_from_queue(gone_enemy)


func on_detection_area_entered(other_object):
	enemy_detected(other_object)


func on_detection_area_exited(other_objet):
	enemy_gone(other_objet)

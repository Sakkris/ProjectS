extends Node3D

@onready var gun_nuzzle = $"../GunNuzzle"
@onready var sight_crosshair = $SightCrosshair

const COLLISION_MASK = 0b101
const RAYCAST_LENGTH = 10
const MIN_DISTANCE_SQUARED = 25
const MIN_SCALE = .5
const MAX_SCALE = 1.0

var space_state: PhysicsDirectSpaceState3D = null


func _physics_process(delta):
	space_state = get_world_3d().direct_space_state
	var raycast_result = get_crosshair_position()
	
	if raycast_result.is_empty():
		sight_crosshair.scale = Vector3(1, 1, 1)
		sight_crosshair.global_position = gun_nuzzle.global_position - gun_nuzzle.global_transform.basis.z * 10
		sight_crosshair.look_at(gun_nuzzle.global_position)
		sight_crosshair.rotate_y(PI)
		
		return
		
	sight_crosshair.visible = true
	sight_crosshair.global_position = raycast_result.position + 0.01 * raycast_result.normal
	
	var new_scale = get_crosshair_scale(gun_nuzzle.global_position.distance_squared_to(sight_crosshair.global_position))
	
	sight_crosshair.scale = Vector3(new_scale, new_scale, new_scale)
	
	if raycast_result.normal != Vector3.UP && raycast_result.normal != Vector3.DOWN:
		sight_crosshair.look_at(sight_crosshair.global_position - raycast_result.normal)
	else:
		sight_crosshair.look_at(sight_crosshair.global_position - raycast_result.normal, Vector3.FORWARD)


func get_crosshair_position():
	var end_pos = gun_nuzzle.global_position - gun_nuzzle.global_transform.basis.z * RAYCAST_LENGTH
	var query = PhysicsRayQueryParameters3D.create(gun_nuzzle.global_position, end_pos)
	
	query.collision_mask = COLLISION_MASK
	
	return space_state.intersect_ray(query)


func get_crosshair_scale(distance_squared):
	var scale_factor = inverse_lerp(MIN_DISTANCE_SQUARED , pow(RAYCAST_LENGTH, 2), distance_squared)
	scale_factor = clamp(scale_factor, 0.0, 1.0)
	
	return lerp(MIN_SCALE, MAX_SCALE, scale_factor)

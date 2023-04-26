extends Node3D

@onready var gun_nuzzle = $"../GunNuzzle"
@onready var sight_crosshair = $SightCrosshair

const COLLISION_MASK = 0b101
const RAYCAST_LENGTH = 100

var space_state: PhysicsDirectSpaceState3D = null


func _physics_process(delta):
	space_state = get_world_3d().direct_space_state
	var raycast_result = get_crosshair_position()
	if raycast_result.is_empty():
		sight_crosshair.visible = false
		return
	
	sight_crosshair.visible = true
	sight_crosshair.global_position = raycast_result.position + 0.01 * raycast_result.normal
	
	if raycast_result.normal != Vector3.UP:
		sight_crosshair.look_at(sight_crosshair.global_position - raycast_result.normal)
	else:
		sight_crosshair.look_at(sight_crosshair.global_position - raycast_result.normal, Vector3.FORWARD)


func get_crosshair_position():
	var end_pos = gun_nuzzle.global_position - gun_nuzzle.global_transform.basis.z * RAYCAST_LENGTH
	var query = PhysicsRayQueryParameters3D.create(gun_nuzzle.global_position, end_pos)
	
	query.collision_mask = COLLISION_MASK
	
	return space_state.intersect_ray(query)

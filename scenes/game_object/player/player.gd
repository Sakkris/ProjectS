extends CharacterBody3D
class_name  Player

signal closest_nav_point_changed

const HEIGHT_OFFSET = .20 # cm
const TURN_ANGLE = 2 * PI / 12

@onready var origin_node = $XROrigin3D
@onready var camera_node = $XROrigin3D/XRCamera3D
@onready var neck_position_node = $XROrigin3D/XRCamera3D/Neck
@onready var velocity_component = $VelocityComponent
@onready var player_collision: CollisionShape3D = $PlayerCollision
@onready var hurt_box: Area3D = $HurtBox

var space_state = null
var closest_nav_point: Vector3 = Vector3.ZERO
var height = 0


func _ready():
	hurt_box.area_entered.connect(hit)
	hurt_box.body_entered.connect(hit)


func _physics_process(delta):
	space_state = get_world_3d().direct_space_state
	
	set_proper_player_collision(delta)
	_process_on_physical_movement(delta)
	velocity_component.move(delta)
	
	var tmp_point = NavPointGenerator.get_closest_point(global_position)
	
	if tmp_point != closest_nav_point:
		closest_nav_point = tmp_point
		closest_nav_point_changed.emit()


func _process_on_physical_movement(delta):
	# Remember our current velocity, we'll apply that later
	var current_velocity = velocity
	
	# Start by rotating the player to face the same way our real player is
	var camera_basis: Basis = origin_node.transform.basis * camera_node.transform.basis
	var forward: Vector2 = Vector2(camera_basis.z.x, camera_basis.z.z)
	var angle: float = forward.angle_to(Vector2(0.0, 1.0))
	
	# Rotate our character body
	transform.basis = transform.basis.rotated(Vector3.UP, angle)
	
	# Reverse this rotation our origin node
	origin_node.transform = Transform3D().rotated(Vector3.UP, -angle) * origin_node.transform
	
	# Now apply movement, first move our player body to the right location
	var org_player_body: Vector3 = global_transform.origin
	var player_body_location: Vector3 = origin_node.transform * camera_node.transform * neck_position_node.transform.origin
	player_body_location.y = 0.0
	player_body_location = global_transform * player_body_location
	
	velocity = (player_body_location - org_player_body) / delta
	move_and_slide()
	
	# Now move our XROrigin back
	var delta_movement = global_transform.origin - org_player_body
	origin_node.global_transform.origin -= delta_movement
	
	# Return our value
	velocity = current_velocity


func set_proper_player_collision(delta):
	var current_height = camera_node.global_transform.origin.y - origin_node.global_transform.origin.y
	
	if current_height <= 0:
		return
	
	player_collision.global_transform.origin.y = ((camera_node.global_transform.origin + origin_node.global_transform.origin).y / 2) + HEIGHT_OFFSET
	player_collision.shape.height = current_height + HEIGHT_OFFSET
	player_collision.shape.radius = 0.3
	
	height = current_height + HEIGHT_OFFSET
	
	origin_node.global_transform.origin.y = global_transform.origin.y
	
	if is_on_floor():
		var query = PhysicsRayQueryParameters3D.create(player_collision.global_transform.origin, global_transform.origin)
		query.collision_mask = 0x0001
		
		var result = space_state.intersect_ray(query)
		
		if result:
			var offset_vector = Vector3.ZERO
			offset_vector.y -= global_transform.origin.y - result.position.y - 0.01
			fix_player_position(offset_vector, delta)


func fix_player_position(offset: Vector3, delta):
	var curr_velocity = velocity_component.velocity
	
	velocity = offset / delta
	move_and_slide()
	
	velocity = curr_velocity


func pause():
	$XROrigin3D/LeftController.change_current_state("Paused")
	$XROrigin3D/RightController.change_current_state("Paused")


func turn_left():
	transform.basis = transform.basis.rotated(Vector3.UP, TURN_ANGLE)


func turn_right():
	transform.basis = transform.basis.rotated(Vector3.UP, -TURN_ANGLE)


func hit(other_area):
	GameEvents.emit_game_over()
	GameEvents.emit_switch_music_request(MusicManager.music_list.GAME_OVER)

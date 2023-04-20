extends CharacterBody3D
class_name  Player

const HEIGHT_OFFSET = .20 # cm

@onready var origin_node = $XROrigin3D
@onready var camera_node = $XROrigin3D/XRCamera3D
@onready var neck_position_node = $XROrigin3D/XRCamera3D/Neck
@onready var velocity_component = $VelocityComponent
@onready var player_collision: CollisionShape3D = $PlayerCollision

var space_state = null


func _ready() -> void:
	$CanvasLayer.visible = false
	$CanvasLayer/Button.pressed.connect(self._on_button_pressed)
	
	if GameProperties.webxr_interface:
		GameEvents.emit_game_start()
		pass
	
	GameProperties.webxr_interface = XRServer.find_interface("WebXR")
	if GameProperties.webxr_interface:
		GameProperties.webxr_interface.session_supported.connect(self._webxr_session_supported)
		GameProperties.webxr_interface.session_started.connect(self._webxr_session_started)
		GameProperties.webxr_interface.session_ended.connect(self._webxr_session_ended)
		GameProperties.webxr_interface.session_failed.connect(self._webxr_session_failed)
		
		GameProperties.webxr_interface.is_session_supported("immersive-vr")


func _physics_process(delta):
	space_state = get_world_3d().direct_space_state
	
	set_proper_player_collision(delta)
	_process_on_physical_movement(delta)
	velocity_component.move(delta)


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
	var left_controller = $XROrigin3D/LeftController
	var right_controller = $XROrigin3D/RightController
	
	left_controller.change_current_state("Paused")
	right_controller.change_current_state("Paused")


func _webxr_session_supported(session_mode: String, supported: bool) -> void:
	if session_mode == 'immersive-vr':
		if supported:
			$CanvasLayer.visible = true
		else:
			OS.alert("Your browser doesn't support VR")
 

func _on_button_pressed() -> void:
	GameProperties.webxr_interface.session_mode = 'immersive-vr'
	GameProperties.webxr_interface.requested_reference_space_types = 'bounded-floor, local-floor, local'
	GameProperties.webxr_interface.required_features = 'local-floor'
	GameProperties.webxr_interface.optional_features = 'bounded-floor'
	
	if not GameProperties.webxr_interface.initialize():
		OS.alert("Failed to initialize WebXR")
		return
 

func _webxr_session_started() -> void:
	$CanvasLayer.visible = false
	
	get_viewport().use_xr = true
	
	GameEvents.emit_game_start()
	print ("Reference space type: " + GameProperties.webxr_interface.reference_space_type)


func _webxr_session_ended() -> void:
	$CanvasLayer.visible = true
	
	get_viewport().use_xr = false
 

func _webxr_session_failed(message: String) -> void:
	OS.alert("Failed to initialize: " + message)

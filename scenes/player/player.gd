extends CharacterBody3D
 
@onready var origin_node = $XROrigin3D
@onready var camera_node = $XROrigin3D/XRCamera3D
@onready var neck_position_node = $XROrigin3D/XRCamera3D/Neck

var webxr_interface
 

func _ready() -> void:
	$CanvasLayer.visible = false
	$CanvasLayer/Button.pressed.connect(self._on_button_pressed)
	
	webxr_interface = XRServer.find_interface("WebXR")
	if webxr_interface:
		webxr_interface.session_supported.connect(self._webxr_session_supported)
		webxr_interface.session_started.connect(self._webxr_session_started)
		webxr_interface.session_ended.connect(self._webxr_session_ended)
		webxr_interface.session_failed.connect(self._webxr_session_failed)
		
		webxr_interface.is_session_supported("immersive-vr")
 

func _webxr_session_supported(session_mode: String, supported: bool) -> void:
	if session_mode == 'immersive-vr':
		if supported:
			$CanvasLayer.visible = true
		else:
			OS.alert("Your browser doesn't support VR")
 

func _on_button_pressed() -> void:
	webxr_interface.session_mode = 'immersive-vr'
	webxr_interface.requested_reference_space_types = 'bounded-floor, local-floor, local'
	webxr_interface.required_features = 'local-floor'
	webxr_interface.optional_features = 'bounded-floor'
	
	if not webxr_interface.initialize():
		OS.alert("Failed to initialize WebXR")
		return
 

func _webxr_session_started() -> void:
	$CanvasLayer.visible = false
	
	get_viewport().use_xr = true
	
	print ("Reference space type: " + webxr_interface.reference_space_type)
 

func _webxr_session_ended() -> void:
	$CanvasLayer.visible = true
	
	get_viewport().use_xr = false
 

func _webxr_session_failed(message: String) -> void:
	OS.alert("Failed to initialize: " + message)


func _process_on_physical_movement(delta) -> bool:
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
	
	if (player_body_location - global_transform.origin).length() > 0.01:
		# We'll talk more about what we'll do here later on
		return true
	else:
		return false


func _get_rotational_input() -> float:
	# Implement this function to return rotation in radians per second.
	return 0.0


func _process_rotation_on_input(delta):
	rotation.y += _get_rotational_input() * delta


func _get_movement_input() -> Vector2:
	# Implement this to return requested directional movement in meters per second.
	return Vector2()


func _process_movement_on_input(delta):
	var movement_input = _get_movement_input()
	var direction = global_transform.basis * Vector3(movement_input.x, 0, movement_input.y)
	
	if direction:
		velocity.x = direction.x
		velocity.z = direction.z
	else:
		velocity.x = move_toward(velocity.x, 0, delta)
		velocity.z = move_toward(velocity.z, 0, delta)
	
	move_and_slide()


func _physics_process(delta):
	var is_colliding = _process_on_physical_movement(delta)
	if !is_colliding:
		_process_rotation_on_input(delta)
		_process_movement_on_input(delta)




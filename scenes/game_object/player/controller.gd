extends XRController3D

@export_enum("Left:1", "Right:2") var controller_id

@onready var grab_area_collision: CollisionShape3D = $GrabArea/CollisionShape3D
@onready var state_manager: StateManager = $StateManager


func _ready():
	PlayerEvents.start_grabbing_request.connect(on_start_grabbing_request)
	PlayerEvents.stop_grabbing_request.connect(on_stop_grabbing_request)
	PlayerEvents.player_changed_state.connect(on_player_changed_state)
	
	button_pressed.connect(self.on_controller_button_pressed)
	button_released.connect(self.on_controller_button_released)
	
	change_state_identifier("unarmed")


func change_state_identifier(new_state):
	var material = $StateIdentifier.material_override
	
	if new_state == "unarmed":
		material.albedo_color = Color(0, 1, 0)
	else:
		material.albedo_color = Color(1, 0, 0)
	
	$StateIdentifier.material_override = material


func on_controller_button_pressed(button: String) -> void:
	match(button):
		"trigger_click":
			state_manager.trigger_pressed()
		"thumbstick_click":
			state_manager.thumbstick_pressed()
		"grip_click":
			state_manager.grip_pressed()
		"ax_button":
			state_manager.ax_button_pressed()
		"by_button":
			state_manager.by_button_pressed()
 

func on_controller_button_released(button: String) -> void:
	match(button):
		"trigger_click":
			state_manager.trigger_released()
		"grip_click":
			state_manager.grip_released()
		"ax_button":
			state_manager.ax_button_released()
		"by_button":
			state_manager.by_button_released()


func on_controller_gun_shot(_controller_id):
	XRServer.primary_interface.trigger_haptic_pulse("haptic", "right_hand", 50, 1.0, 1.0, 0.0)


func on_start_grabbing_request(signal_controller_id: int):
	if controller_id == signal_controller_id:
		grab_area_collision.disabled = false


func on_stop_grabbing_request(signal_controller_id: int):
	if controller_id == signal_controller_id:
		grab_area_collision.disabled = true


func on_player_changed_state(signal_controller_id, new_state):
	if signal_controller_id != controller_id:
		return
	
	if new_state == "unarmed" || new_state == "armed":
		change_state_identifier(new_state)

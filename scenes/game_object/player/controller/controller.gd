extends XRController3D

@export_enum("Left:1", "Right:2") var controller_id

@onready var grab_area_collision: CollisionShape3D = $GrabArea/CollisionShape3D 
@onready var state_machine: StateMachine = $StateMachine


func _ready():
#	PlayerEvents.start_grabbing_request.connect(on_start_grabbing_request)
#	PlayerEvents.stop_grabbing_request.connect(on_stop_grabbing_request)
#	PlayerEvents.player_changed_state.connect(on_player_changed_state)
#
	button_pressed.connect(self.on_controller_button_pressed)
	button_released.connect(self.on_controller_button_released)
	state_machine.transitioned.connect(on_player_changed_state)
	
	change_state_identifier("Unarmed")


func change_state_identifier(new_state):
	var material = $StateIdentifier.material_override
	
	if new_state == "Unarmed":
		material.albedo_color = Color(0, 1, 0)
	elif new_state == "Armed":
		material.albedo_color = Color(1, 0, 0)
	elif new_state == "Hooking":
		material.albedo_color = Color(1, 1, 0)
	
	$StateIdentifier.material_override = material


func on_controller_button_pressed(button: String) -> void:
	state_machine.handle_input_pressed(button)


func on_controller_button_released(button: String) -> void:
	state_machine.handle_input_released(button)


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
	
	change_state_identifier(new_state)

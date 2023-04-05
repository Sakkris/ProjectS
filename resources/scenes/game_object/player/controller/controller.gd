extends XRController3D

@onready var grab_area_collision: CollisionShape3D = $GrabArea/CollisionShape3D 
@onready var state_machine: StateMachine = $StateMachine


func _ready():
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


func on_player_changed_state(signal_controller_id, new_state):
	if signal_controller_id != get_tracker_hand():
		return
	
	change_state_identifier(new_state)

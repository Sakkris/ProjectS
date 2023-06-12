extends XRController3D

@export var player_ui: Node3D 

@onready var grab_area_collision: CollisionShape3D = $GrabArea/CollisionShape3D 
@onready var state_machine: StateMachine = $StateMachine

var just_turned: bool = false


func _ready():
	button_pressed.connect(self.on_controller_button_pressed)
	button_released.connect(self.on_controller_button_released)
	input_vector2_changed.connect(on_thumbstick_moved)
	state_machine.transitioned.connect(on_player_changed_state)
	
	change_state_identifier("Unarmed")


func change_state_identifier(new_state):
	var material = $StateIdentifier.material_override
	
	match new_state:
		"Unarmed":
			material.albedo_color = Color(0, 1, 0)
		"Armed":
			material.albedo_color = Color(1, 0, 0)
		"Hooking":
			material.albedo_color = Color(1, 1, 0)
		"Paused":
			material.albedo_color = Color(1, 1, 1)
	
	player_ui.change_indicator_icon(get_tracker_hand(), new_state)
	
	$StateIdentifier.material_override = material


func change_current_state(new_state: String):
	state_machine.transition_to(new_state)


func on_controller_button_pressed(button: String) -> void:
	state_machine.handle_input_pressed(button)


func on_controller_button_released(button: String) -> void:
	state_machine.handle_input_released(button)


func on_thumbstick_moved(button_name: String, value: Vector2): 
	if button_name == "thumbstick":
		if !just_turned:
			if value.x > 0.5:
				owner.turn_right()
				just_turned = true
			elif value.x < -0.5:
				owner.turn_left()
				just_turned = true
		elif value.x > -0.5 && value.x < 0.5:
			just_turned = false


func on_player_changed_state(signal_controller_id, new_state):
	if signal_controller_id != get_tracker_hand():
		return
	
	change_state_identifier(new_state)

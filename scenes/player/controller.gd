extends XRController3D

@export_enum("Left:1", "Right:2") var controller_id

var state_manager

func _ready():
	button_pressed.connect(self._on_controller_button_pressed)
	button_released.connect(self._on_controller_button_released)
	
	if controller_id == 1:
		state_manager = $LeftStateManager
	elif controller_id == 2:
		state_manager = $RightStateManager


func _on_controller_button_pressed(button: String) -> void:
	match(button):
		"trigger_click":
			state_manager.trigger_pressed()
		"thumbstick_click":
			state_manager.thumbstick_pressed()
 

func _on_controller_button_released(button: String) -> void:
	match(button):
		"trigger_click":
			state_manager.trigger_released()


func _on_controller_gun_shot(_controller_id):
	XRServer.primary_interface.trigger_haptic_pulse("haptic", "right_hand", 50, 1.0, 1.0, 0.0)

extends XRController3D


const CONTROLLER_ID = 2

var state_manager


func _ready():
	button_pressed.connect(self._on_right_controller_button_pressed)
	button_released.connect(self._on_right_controller_button_released)
	
	state_manager = $RightStateManager


func _on_right_controller_button_pressed(button: String) -> void:
	match(button):
		"trigger_click":
			state_manager.trigger_pressed()
		"thumbstick_click":
			state_manager.thumbstick_pressed()
 

func _on_right_controller_button_released(button: String) -> void:
	match(button):
		"trigger_click":
			state_manager.trigger_released()


func _on_controller_gun_shot(controller_id):
	XRServer.primary_interface.trigger_haptic_pulse("haptic", "right_hand", 50, 1.0, 1.0, 0.0)

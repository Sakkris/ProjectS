extends XRController3D


signal shooting_request(controller_id: int)
signal stop_shooting_request(controller_id: int)

const CONTROLLER_ID = 2

func _ready():
	button_pressed.connect(self._on_right_controller_button_pressed)
	button_released.connect(self._on_right_controller_button_released)


func _on_right_controller_button_pressed(button: String) -> void:
	match(button):
		"trigger_click":
			shooting_request.emit(CONTROLLER_ID)
		"thumbstick_click":
			# Mudar de estado 
			shooting_request.emit(CONTROLLER_ID)
 

func _on_right_controller_button_released(button: String) -> void:
	match(button):
		"trigger_click":
			stop_shooting_request.emit(CONTROLLER_ID)


func _on_controller_gun_shot(controller_id):
	XRServer.primary_interface.trigger_haptic_pulse("haptic", "right_hand", 50, 1.0, 1.0, 0.0)

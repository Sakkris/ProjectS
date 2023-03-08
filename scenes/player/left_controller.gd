extends XRController3D


signal shooting_request(controller_id: int)
signal stop_shooting_request(controller_id: int)

const CONTROLLER_ID = 1 # Id = 1 = Left


func _ready():
	button_pressed.connect(self._on_left_controller_button_pressed)
	button_released.connect(self._on_left_controller_button_released)


func _on_left_controller_button_pressed(button: String) -> void:
	match(button):
		"trigger_click":
			shooting_request.emit(CONTROLLER_ID)
		"thumbstick_click":
			shooting_request.emit(CONTROLLER_ID)
 

func _on_left_controller_button_released(button: String) -> void:
	match(button):
		"trigger_click":
			stop_shooting_request.emit(CONTROLLER_ID)
		

extends BaseState

class_name MovingState


func ax_button_pressed():
	GameEvents.emit_start_boosting_request(controller_id)


func ax_button_released():
	GameEvents.emit_stop_boosting_request(controller_id)


func by_button_pressed():
	GameEvents.emit_start_braking_request(controller_id)


func by_button_released():
	GameEvents.emit_stop_braking_request(controller_id)

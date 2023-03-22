extends BaseState
class_name MovingState


func ax_button_pressed():
	if controller_id == 1:
		GameEvents.emit_start_braking_request()
	elif controller_id == 2:
		GameEvents.emit_start_boosting_request()


func ax_button_released():
	if controller_id == 1:
		GameEvents.emit_stop_braking_request()
	elif controller_id == 2:
		GameEvents.emit_stop_boosting_request()

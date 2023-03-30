extends ControllerState
class_name MovingStateR 


func enter(_msg = {}):
	controller.button_pressed.connect(on_controller_button_pressed)
	controller.button_released.connect(on_controller_button_released)


func ax_button_pressed():
	if controller_id == 1:
		PlayerEvents.emit_start_braking_request()
	elif controller_id == 2:
		PlayerEvents.emit_start_boosting_request()


func ax_button_released():
	if controller_id == 1:
		PlayerEvents.emit_stop_braking_request()
	elif controller_id == 2:
		PlayerEvents.emit_stop_boosting_request()


func on_controller_button_pressed(button: String):
	if button == "ax_button":
		ax_button_pressed()


func on_controller_button_released(button: String):
	if button == "ax_button":
		ax_button_released()

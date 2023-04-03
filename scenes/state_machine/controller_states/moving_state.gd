extends ControllerState
class_name MovingStateR 


func enter(_msg = {}):
	super.enter(_msg)
	
	controller.button_pressed.connect(on_controller_button_pressed)
	controller.button_released.connect(on_controller_button_released)


func ax_button_pressed():
	if controller_id == 1:
		ability_manager.use_ability("Brake")
	elif controller_id == 2:
		ability_manager.use_ability("Boost")


func ax_button_released():
	if controller_id == 1:
		ability_manager.stop_ability("Brake")
	elif controller_id == 2:
		ability_manager.stop_ability("Boost")


func on_controller_button_pressed(button: String):
	if button == "ax_button":
		ax_button_pressed()


func on_controller_button_released(button: String):
	if button == "ax_button":
		ax_button_released()

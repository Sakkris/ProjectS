extends ControllerState
class_name MovingState


func _ready():
	super()

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


func handle_input_pressed(button: String):
	if button == "ax_button":
		ax_button_pressed()


func handle_input_released(button: String):
	if button == "ax_button":
		ax_button_released()

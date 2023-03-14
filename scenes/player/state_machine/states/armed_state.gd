extends MovingState
class_name ArmedState


func _ready():
	print("Armed State")


func thumbstick_pressed():
	change_state.call("unarmed")


func trigger_pressed():
	change_state.call("shooting")


func by_button_pressed():
	GameEvents.emit_dash_request(controller_id)


func grip_pressed():
	GameEvents.emit_start_thrusting_request(controller_id)


func grip_released():
	GameEvents.emit_stop_thrusting_request(controller_id)
